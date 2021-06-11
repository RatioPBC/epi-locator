defmodule EpiLocatorWeb.SearchLiveTest do
  use EpiLocatorWeb.ConnCase

  import Phoenix.LiveViewTest

  import Mox
  alias EpiLocator.Search.Cache
  alias EpiLocatorWeb.SearchLive
  alias EpiLocatorWeb.Test.Components
  alias EpiLocatorWeb.Test.Pages

  setup :verify_on_exit!

  @ref_time DateTime.utc_now()

  setup %{conn: conn} do
    case_id = "fixture-case-id"
    domain = "fixture-domain"
    request_id = "iAmTheRequestIdAndIMustBeOver20CharactersToWork"
    conn = put_req_header(conn, "x-request-id", request_id)

    stub(EpiLocator.TimeMock, :utc_now, fn -> @ref_time end)

    {:ok, system_stub_agent_pid} = Agent.start(fn -> 10 end)

    Mox.stub(EpiLocator.SystemMock, :monotonic_time, fn :millisecond ->
      Agent.get_and_update(system_stub_agent_pid, fn state -> {state, state + 50} end)
    end)

    on_exit(fn ->
      :ok = Agent.stop(system_stub_agent_pid)
      {:ok, _} = Cache.clear()
    end)

    %{case_id: case_id, conn: conn, domain: domain, request_id: request_id, user_id: "qwe123"}
  end

  describe "when not logged in" do
    test "it redirects to root", %{conn: conn} do
      Mox.expect(PatientCaseProviderMock, :get_patient_case, 0, fn _, _ -> :ok end)
      Mox.expect(LookupApiBehaviourMock, :lookup_person, 0, fn _ -> :ok end)

      conn = get(conn, "/search")
      assert redirected_to(conn) == "/access-denied"
      assert %{"error" => "You must log in to access this page."} = get_flash(conn)
    end
  end

  describe "when logged in, with NO Commcare connection" do
    setup do
      Mox.expect(PatientCaseProviderMock, :get_patient_case, 1, fn _, _ -> {:error, "something wicked"} end)
      Mox.expect(LookupApiBehaviourMock, :lookup_person, 0, fn _ -> :ok end)

      :ok
    end

    setup [:log_in_and_render]

    test "it shows the error screen", %{html: html, request_id: request_id} do
      assert html =~ "Something went wrong."
      assert html =~ "#{request_id}"
    end
  end

  describe "when logged in, with GOOD Commcare, but NO TRClient connection," do
    setup do
      Mox.expect(LookupApiBehaviourMock, :lookup_person, 1, fn _ -> {:error, "lookup_person has failed"} end)

      [telemetry_event_name: :error]
    end

    setup [:stub_successful_commcare_response, :setup_telemetry, :log_in_and_render]

    test "it shows the Commcare user", %{html: html} do
      assert html =~ "<h3>Firstname Lastname</h3>"
    end

    test "it shows the error screen", %{html: html, request_id: request_id} do
      assert html =~ "Something went wrong."
      assert html =~ "#{request_id}"
    end

    test "emits a telemetry event to record the error", %{case_id: case_id, domain: domain, user_id: user_id} do
      assert_receive {:telemetry_event, [:epi_locator, :tr, :search, :error], %{},
                      %{
                        case_type: "patient",
                        case_id: ^case_id,
                        domain: ^domain,
                        module: SearchLive,
                        msec_elapsed: 50,
                        timestamp: @ref_time,
                        user: ^user_id
                      }}
    end
  end

  describe "when logged in, with GOOD Commcare, and GOOD TR, but with NO TR results" do
    setup do
      Mox.expect(LookupApiBehaviourMock, :lookup_person, 1, fn _ -> {:error, :no_results, "no search results URL returned from Thomson Reuters"} end)

      [telemetry_event_name: :no_results]
    end

    setup [:stub_successful_commcare_response, :setup_telemetry, :log_in_and_render]

    test "it shows the Commcare user", %{html: html} do
      assert html =~ "<h3>Firstname Lastname</h3>"
    end

    test "it shows the no_results screen", %{html: html} do
      assert html =~ "No results found"
    end

    test "emits a telemetry event to record no results", %{case_id: case_id, domain: domain, user_id: user_id} do
      assert_receive {:telemetry_event, [:epi_locator, :tr, :search, :no_results], %{},
                      %{
                        case_id: ^case_id,
                        case_type: "patient",
                        domain: ^domain,
                        module: SearchLive,
                        msec_elapsed: 50,
                        timestamp: @ref_time,
                        user: ^user_id
                      }}
    end
  end

  describe "when logged in, with GOOD Commcare, and GOOD TR, and 1 returned person match" do
    setup do
      [telemetry_event_name: :success, number_of_people_returned_by_tr: 1]
    end

    setup [
      :stub_successful_commcare_response,
      :stub_successful_tr_response,
      :setup_telemetry,
      :log_in_and_render
    ]

    test "it shows the Commcare user", %{html: html} do
      assert html =~ "<h3>Firstname Lastname</h3>"
    end

    test "it shows the search results", %{html: html} do
      assert html =~ "JOHN1 DOE1"
      assert html =~ "4544454555"
      assert html =~ "123 MARKET ST FL 3, TestCity, NY 12831"
    end

    test "emits a telemetry event to record the result count", %{case_id: case_id, domain: domain, user_id: user_id} do
      assert_receive {:telemetry_event, [:epi_locator, :tr, :search, :success], %{},
                      %{
                        case_id: ^case_id,
                        case_type: "patient",
                        count: 1,
                        domain: ^domain,
                        module: SearchLive,
                        msec_elapsed: 50,
                        timestamp: @ref_time,
                        user: ^user_id
                      }}
    end
  end

  describe "when logged in, with GOOD Commcare, and GOOD TR, and 1 returned person match with parent/guardian" do
    setup do
      [telemetry_event_name: :success, number_of_people_returned_by_tr: 1]
    end

    setup [
      :stub_interviewee_parent_name,
      :stub_successful_commcare_response,
      :stub_successful_tr_response,
      :setup_telemetry,
      :log_in_and_render
    ]

    @tag :skip
    test "it shows the parent/guardian", %{interviewee_parent_name: interviewee_parent_name, html: html} do
      assert html =~ "Index case has a parent/guardian present. Select the index case or parent/guardian below to search."
      assert html =~ interviewee_parent_name
    end

    @tag :skip
    test "it shows the Commcare user", %{html: html} do
      assert html =~ "<h3>Firstname Lastname</h3>"
    end

    @tag :skip
    test "it shows the search results", %{html: html, view: view} do
      assert html =~ "Index case has a parent/guardian present. Select the index case or parent/guardian below to search."

      html =
        view
        |> element("form")
        |> render_change(%{search_chooser: %{source: "index_case"}})

      assert html =~ "4544454555"
      assert html =~ "123 MARKET ST FL 3, TestCity, NY 12831"
    end

    @tag :skip
    test "emits a telemetry event to record the result count", %{case_id: case_id, domain: domain, user_id: user_id} do
      assert_receive {:telemetry_event, [:epi_locator, :tr, :search, :success], %{},
                      %{
                        case_id: ^case_id,
                        case_type: "patient",
                        count: 1,
                        domain: ^domain,
                        module: SearchLive,
                        msec_elapsed: 50,
                        timestamp: @ref_time,
                        user: ^user_id
                      }}
    end
  end

  describe "when logged in, with GOOD Commcare, and GOOD TR, and multiple (5) returned persons match" do
    setup do
      [telemetry_event_name: :success, number_of_people_returned_by_tr: 5]
    end

    setup [:stub_successful_commcare_response, :stub_successful_tr_response, :setup_telemetry, :log_in_and_render]

    test "it shows the Commcare user", %{html: html} do
      assert html =~ "<h3>Firstname Lastname</h3>"
    end

    test "it shows the count of people in the search results", %{html: html} do
      assert html =~ "5 results"
    end

    test "it shows all the people in the search results", %{html: html} do
      number_of_johns = Regex.scan(~r/JOHN\d DOE\d/, html) |> length()
      assert number_of_johns == 5

      assert html =~ "JOHN1 DOE1"
      assert html =~ "JOHN2 DOE2"
      assert html =~ "JOHN3 DOE3"
      assert html =~ "JOHN4 DOE4"
      assert html =~ "JOHN5 DOE5"
    end

    test "it does not show a button to show all the results", %{html: html} do
      refute html =~ ~r"Show \d+ more result\(s\)"
    end

    test "emits a telemetry event to record the result count", %{case_id: case_id, domain: domain, user_id: user_id} do
      assert_receive {:telemetry_event, [:epi_locator, :tr, :search, :success], %{},
                      %{
                        case_id: ^case_id,
                        case_type: "patient",
                        count: 5,
                        domain: ^domain,
                        module: SearchLive,
                        msec_elapsed: 50,
                        timestamp: @ref_time,
                        user: ^user_id
                      }}
    end
  end

  describe "when logged in, with GOOD Commcare, and GOOD TR, and very many returned persons (more than 5)" do
    setup do
      [telemetry_event_name: :success, number_of_people_returned_by_tr: 6]
    end

    setup [:stub_successful_commcare_response, :stub_successful_tr_response, :setup_telemetry, :log_in_and_render]

    test "it shows the Commcare user", %{html: html} do
      assert html =~ "<h3>Firstname Lastname</h3>"
    end

    test "it shows the count of people in the search results is greater than 5", %{html: html} do
      assert html =~ "5+ results"
    end

    test "it shows only the first 5 contacts by default", %{html: html} do
      number_of_johns = Regex.scan(~r/JOHN\d DOE\d/, html) |> length()
      assert number_of_johns == 5

      assert html =~ "JOHN1 DOE1"
      assert html =~ "JOHN2 DOE2"
      assert html =~ "JOHN3 DOE3"
      assert html =~ "JOHN4 DOE4"
      assert html =~ "JOHN5 DOE5"
      refute html =~ "JOHN6 DOE6"
    end

    test "it shows a button to show all the results", %{view: view} do
      html = view |> element(".show-all-results", "Show 1 more result(s)") |> render_click

      number_of_johns = Regex.scan(~r/JOHN\d DOE\d/, html) |> length()
      assert number_of_johns == 6
      assert html =~ "JOHN6 DOE6"
    end

    test "it hides the show more results button after being clicked", %{view: view} do
      html = view |> element(".show-all-results", "Show 1 more result(s)") |> render_click
      refute html =~ ~r"Show \d+ more result\(s\)"
    end

    test "emits a telemetry event to record the result count", %{case_id: case_id, domain: domain, user_id: user_id} do
      assert_receive {:telemetry_event, [:epi_locator, :tr, :search, :success], %{},
                      %{
                        case_id: ^case_id,
                        case_type: "patient",
                        count: 6,
                        domain: ^domain,
                        module: SearchLive,
                        msec_elapsed: 50,
                        timestamp: @ref_time,
                        user: ^user_id
                      }}
    end
  end

  describe "refining results" do
    setup [:stub_successful_commcare_response]

    setup %{conn: conn} do
      [conn: log_in_user(conn, "abc123")]
    end

    test "does not show the refine results form when the refine results feature flag is turned on and there are zero person results", %{case_id: case_id, conn: conn, domain: domain} do
      {:ok, true} = FunWithFlags.enable(SearchLive.refine_results_flag_name(), [])
      Mox.stub(LookupApiBehaviourMock, :lookup_person, fn _ -> {:ok, []} end)

      refute Pages.SearchLive.visit(conn, case_id, domain) |> Components.RefineSearchResults.visible?()
    end

    test "does not show the refine results form when the refine results feature flag is turned on and there is only one person result", %{case_id: case_id, conn: conn, domain: domain} do
      {:ok, true} = FunWithFlags.enable(SearchLive.refine_results_flag_name(), [])

      stub_successful_tr_response(%{number_of_people_returned_by_tr: 1})

      refute Pages.SearchLive.visit(conn, case_id, domain) |> Components.RefineSearchResults.visible?()
    end

    test "does not show the refine results form when there are many results and the refine results feature flag is turned off", %{case_id: case_id, conn: conn, domain: domain} do
      {:ok, false} = FunWithFlags.disable(SearchLive.refine_results_flag_name(), [])
      stub_successful_tr_response(%{number_of_people_returned_by_tr: 2})

      refute Pages.SearchLive.visit(conn, case_id, domain) |> Components.RefineSearchResults.visible?()
    end

    test "shows the refine results form when the refine results feature flag is turned on and there are many results", %{case_id: case_id, conn: conn, domain: domain} do
      {:ok, true} = FunWithFlags.enable(SearchLive.refine_results_flag_name(), [])
      stub_successful_tr_response(%{number_of_people_returned_by_tr: 2})

      assert Pages.SearchLive.visit(conn, case_id, domain) |> Components.RefineSearchResults.visible?()
    end

    test "can filter search results", %{case_id: case_id, conn: conn, domain: domain} do
      alias EpiLocator.{Repo, RefinementLog}
      assert RefinementLog |> Repo.all() |> length == 0
      {:ok, true} = FunWithFlags.enable(SearchLive.refine_results_flag_name(), [])

      Mox.stub(LookupApiBehaviourMock, :lookup_person, fn _ ->
        person_results = [
          %EpiLocator.Search.PersonResult{
            city: "City",
            dob: "05/05/1987",
            email_addresses: ["john@example.com"],
            first_name: "JOHN1",
            last_name: "Lastname",
            middle_name: nil,
            phone_numbers: [
              %EpiLocator.Search.PhoneNumber{
                phone: "matching phone",
                source: ["Work Affiliations"]
              }
            ],
            reported_date: nil,
            state: "NY",
            street: "123 MARKET ST FL 3",
            zip_code: "94103"
          },
          %EpiLocator.Search.PersonResult{
            city: "Other City",
            dob: "05/05/1987",
            email_addresses: ["john@example.com"],
            first_name: "JOHN2",
            last_name: "Lastname",
            middle_name: nil,
            phone_numbers: [
              %EpiLocator.Search.PhoneNumber{
                phone: "other phone",
                source: ["Work Affiliations"]
              }
            ],
            reported_date: nil,
            state: "CA",
            street: "123 MARKET ST FL 3",
            zip_code: "94103"
          }
        ]

        {:ok, person_results}
      end)

      view = Pages.SearchLive.visit(conn, case_id, domain)

      assert ["JOHN1 Lastname", "JOHN2 Lastname"] = view |> Pages.SearchLive.visible_person_result_names()

      Components.RefineSearchResults.refine_results(view, %{
        "first_name" => "JOHN1",
        "city" => "City",
        "state" => "NY",
        "phone" => "matching phone",
        "dob_year" => "1987",
        "dob_month" => "",
        "dob_day" => ""
      })

      assert [
               %RefinementLog{
                 first_name: true,
                 last_name: false,
                 phone: true,
                 dob: true,
                 state: true,
                 user: "qwe123",
                 domain: "fixture-domain",
                 case_type: "patient",
                 total_results: 2,
                 refined_results: 1
               }
             ] = RefinementLog |> Repo.all()

      assert ["JOHN1 Lastname"] = view |> Pages.SearchLive.visible_person_result_names()
    end

    test "refining results shows a count of matching results", %{case_id: case_id, conn: conn, domain: domain} do
      {:ok, true} = FunWithFlags.enable(SearchLive.refine_results_flag_name(), [])
      stub_successful_tr_response(%{number_of_people_returned_by_tr: 2})

      view = Pages.SearchLive.visit(conn, case_id, domain)

      refute view |> Pages.SearchLive.showing_refined_results_count?()

      Components.RefineSearchResults.refine_results(view, %{"first_name" => "JOHN1"})

      assert view |> Pages.SearchLive.refined_results_count() == "Showing 1 refined results of 2"
    end

    test "can exit refined mode to show all results again", %{case_id: case_id, conn: conn, domain: domain} do
      {:ok, true} = FunWithFlags.enable(SearchLive.refine_results_flag_name(), [])

      stub_successful_tr_response(%{number_of_people_returned_by_tr: 2})

      view = Pages.SearchLive.visit(conn, case_id, domain)

      assert Pages.SearchLive.visible_person_result_names(view) == ["JOHN1 DOE1", "JOHN2 DOE2"]

      Components.RefineSearchResults.refine_results(view, %{"first_name" => "JOHN1"})

      assert Pages.SearchLive.visible_person_result_names(view) == ["JOHN1 DOE1"]

      Components.RefineSearchResults.click_reset_button(view)

      assert Pages.SearchLive.visible_person_result_names(view) == ["JOHN1 DOE1", "JOHN2 DOE2"]
    end

    test "shows an appropriate message when no results match the filters", %{case_id: case_id, conn: conn, domain: domain} do
      {:ok, true} = FunWithFlags.enable(SearchLive.refine_results_flag_name(), [])

      stub_successful_tr_response(%{number_of_people_returned_by_tr: 2})

      view = Pages.SearchLive.visit(conn, case_id, domain)
      refute Pages.SearchLive.showing_no_matching_refined_results?(view)

      Components.RefineSearchResults.refine_results(view, %{"first_name" => "This won't match"})
      assert Pages.SearchLive.visible_person_result_names(view) == []

      assert Pages.SearchLive.showing_no_matching_refined_results?(view)
      Components.RefineSearchResults.click_reset_button(view)
      refute Pages.SearchLive.showing_no_matching_refined_results?(view)
    end
  end

  defp log_in_and_render(%{case_id: case_id, conn: conn, domain: domain}) do
    conn = log_in_user(conn, "abc123")
    {:ok, view, _mount_html} = live(conn, "/search?user-id=qwe123&case-id=#{case_id}&domain=#{domain}")
    search_html = render(view)

    %{html: search_html, view: view}
  end

  defp make_person(n) do
    %EpiLocator.Search.PersonResult{
      city: "TestCity",
      dob: "05/05/1987",
      email_addresses: ["john@example.com"],
      first_name: "JOHN#{n}",
      last_name: "DOE#{n}",
      middle_name: nil,
      phone_numbers: [
        %EpiLocator.Search.PhoneNumber{
          phone: "4544454555",
          source: ["Work Affiliations"]
        }
      ],
      reported_date: nil,
      state: "NY",
      street: "123 MARKET ST FL 3",
      zip_code: "12831",
      address: "123 MARKET ST FL 3, TestCity, NY 12831"
    }
  end

  defp setup_telemetry(%{telemetry_event_name: event_name, test: test}) do
    self = self()

    :ok =
      :telemetry.attach_many(
        "#{test}",
        [
          [:epi_locator, :tr, :search, event_name]
        ],
        fn name, measurements, metadata, _ ->
          send(self, {:telemetry_event, name, measurements, metadata})
        end,
        nil
      )

    :ok
  end

  defp stub_successful_commcare_response(%{case_id: case_id, domain: domain} = params) do
    Mox.expect(PatientCaseProviderMock, :get_patient_case, 1, fn _, _ ->
      patient_stub = %CommcareAPI.PatientCase{
        case_id: case_id,
        case_type: "patient",
        city: "TestCity",
        date_tested: ~D[2020-05-13],
        dob: ~D[1987-05-05],
        domain: domain,
        first_name: "Firstname",
        full_name: "Firstname Lastname",
        last_name: "Lastname",
        owner_id: "000000009299465ab175357b95b89e7c",
        phone_home: "4544454555",
        state: "NY",
        street: "12 Main st",
        zip_code: "12831",
        interviewee_parent_name: params[:interviewee_parent_name]
      }

      {:ok, patient_stub}
    end)

    :ok
  end

  defp stub_interviewee_parent_name(context) do
    Map.put(context, :interviewee_parent_name, "A Parent/Guardian")
  end

  defp stub_successful_tr_response(%{number_of_people_returned_by_tr: number_of_people}) do
    Mox.expect(LookupApiBehaviourMock, :lookup_person, 1, fn _ ->
      person_results = for n <- 1..number_of_people, do: make_person(n)
      {:ok, person_results}
    end)

    :ok
  end
end
