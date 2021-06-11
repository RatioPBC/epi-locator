defmodule EpiLocatorWeb.LiveComponents.RefineSearchResultsTest do
  use EpiLocatorWeb.ConnCase, async: true
  use Plug.Test

  import EpiLocatorWeb.LiveComponents.Helpers
  import Phoenix.LiveViewTest

  alias EpiLocatorWeb.Test
  alias EpiLocatorWeb.Test.Components

  defmodule TestLiveView do
    @moduledoc false
    alias EpiLocatorWeb.LiveComponents.RefineSearchResults

    @patient_case %CommcareAPI.PatientCase{
      case_id: "00000000-8434-4475-b111-bb3a902b398b",
      case_type: "patient",
      city: "Test",
      date_tested: ~D[2020-05-13],
      dob: ~D[1987-05-05],
      domain: "ny-state-covid19",
      first_name: "Firstname",
      full_name: "Firstname McLastName",
      last_name: "McLastName",
      owner_id: "000000009299465ab175357b95b89e7c",
      phone_home: "4544454555",
      state: "NY",
      street: "12 Main st",
      zip_code: "12831"
    }
    @search_case_or_parent_guardian "index_case"

    use EpiLocatorWeb.Test.ComponentEmbeddingLiveView,
      default_assigns: [
        search_case_or_parent_guardian: @search_case_or_parent_guardian,
        patient_case: @patient_case,
        on_refine_search_results: &Function.identity/1,
        on_reset_refine_form: &Function.identity/1
      ]

    def render(assigns) do
      ~L"""
      <%= component(
        @socket,
        RefineSearchResults,
        "refine-search-result",
        search_case_or_parent_guardian: @search_case_or_parent_guardian,
        patient_case: @patient_case,
        on_refine_search_results: @on_refine_search_results,
        on_reset_refine_form: @on_reset_refine_form
      ) %>
      """
    end

    def patient_case, do: @patient_case
  end

  setup context do
    search_case_or_parent_guardian = Map.get(context, :search_case_or_parent_guardian, "index_case")
    interviewee_parent_name = "Some Interviewee Parent Name"
    patient_case = patient_case(search_case_or_parent_guardian, interviewee_parent_name)

    assigns = %{
      patient_case: patient_case,
      search_case_or_parent_guardian: search_case_or_parent_guardian,
      id: "some-id"
    }

    [assigns: assigns, patient_case: patient_case]
  end

  defp patient_case("index_case", _interviewee_parent_name), do: TestLiveView.patient_case()
  defp patient_case("parent_guardian", interviewee_parent_name), do: %{TestLiveView.patient_case() | interviewee_parent_name: interviewee_parent_name}

  test "has the correct data role", %{assigns: assigns} do
    assert EpiLocatorWeb.LiveComponents.RefineSearchResults
           |> render_component(assigns)
           |> Test.Html.parse()
           |> Test.Html.has_role?("refine-results")
  end

  @tag search_case_or_parent_guardian: "index_case"
  test "prefills the form with the details of the patient case", %{conn: conn} do
    {:ok, view, _html} = live_isolated(conn, TestLiveView)

    assert "Firstname" = Components.RefineSearchResults.first_name(view)
    assert "McLastName" = Components.RefineSearchResults.last_name(view)
    assert "Test" = Components.RefineSearchResults.city(view)
    assert "NY" = Components.RefineSearchResults.state(view)
    assert "4544454555" = Components.RefineSearchResults.phone(view)
    assert {"1987", "05", "05"} = Components.RefineSearchResults.dob(view)
  end

  @tag search_case_or_parent_guardian: "parent_guardian"
  test "prefills the form with the details of the parent/guardian", %{conn: conn} do
    {:ok, view, _html} = live_isolated(conn, TestLiveView)

    interviewee_parent_name = "Some Interviewee Parent Name"
    patient_case = %{TestLiveView.patient_case() | interviewee_parent_name: interviewee_parent_name}
    send(view.pid, {:assigns, search_case_or_parent_guardian: "parent_guardian", patient_case: patient_case})

    assert "Some" = Components.RefineSearchResults.first_name(view)
    assert "Interviewee Parent Name" = Components.RefineSearchResults.last_name(view)
    assert "Test" = Components.RefineSearchResults.city(view)
    assert "NY" = Components.RefineSearchResults.state(view)
    assert "4544454555" = Components.RefineSearchResults.phone(view)
    assert {"", "", ""} = Components.RefineSearchResults.dob(view)
  end

  test "leaves dob values unselected if they are not present on the patient case", %{conn: conn} do
    {:ok, view, _html} = live_isolated(conn, TestLiveView)

    patient_case = %CommcareAPI.PatientCase{
      case_id: "00000000-8434-4475-b111-bb3a902b398b",
      case_type: "patient",
      city: "Test",
      date_tested: ~D[2020-05-13],
      dob: "Unavailable",
      domain: "ny-state-covid19",
      first_name: "Firstname",
      full_name: "Firstname McLastName",
      last_name: "McLastName",
      owner_id: "000000009299465ab175357b95b89e7c",
      phone_home: "4544454555",
      state: "NY",
      street: "12 Main st",
      zip_code: "12831"
    }

    send(view.pid, {:assigns, search_case_or_parent_guardian: "index_case", patient_case: patient_case})
    assert Components.RefineSearchResults.dob_components_are_blank?(view)
  end

  describe "resetting the form" do
    test "reset button resets the form back to its original state", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestLiveView)

      assert "Firstname" = Components.RefineSearchResults.first_name(view)

      Components.RefineSearchResults.change_form(view, %{"first_name" => "Bob"})

      assert "Bob" = Components.RefineSearchResults.first_name(view)

      Components.RefineSearchResults.click_reset_button(view)

      assert "Firstname" = Components.RefineSearchResults.first_name(view)
    end

    test "resetting the form calls the reset callback", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestLiveView)
      pid = self()
      on_reset_refine_form = fn _params -> send(pid, :received_on_reset_refine_form) end
      send(view.pid, {:assigns, on_reset_refine_form: on_reset_refine_form})

      Components.RefineSearchResults.change_form(view, %{"first_name" => "Bob"})
      Components.RefineSearchResults.click_reset_button(view)

      assert_receive :received_on_reset_refine_form
    end
  end

  describe "submitting the form" do
    test "submitting the form calls the refine callback with filter params", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestLiveView)

      pid = self()
      on_refine_search_results = fn filters -> send(pid, {:received_on_refine_search_results, filters}) end
      send(view.pid, {:assigns, on_refine_search_results: on_refine_search_results})

      view
      |> Components.RefineSearchResults.refine_results(%{
        "first_name" => "Submitted Firstname",
        "city" => "Burlington",
        "state" => "VT",
        "phone" => "1112223333",
        "dob_year" => "1983",
        "dob_month" => "01",
        "dob_day" => "02"
      })

      assert_receive {:received_on_refine_search_results, %{first_name: "Submitted Firstname", city: "Burlington", state: "VT", phone: "1112223333", dob: %{year: "1983", month: "01", day: "02"}}}
    end

    test "blank fields are omitted", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestLiveView)

      pid = self()
      on_refine_search_results = fn filters -> send(pid, {:received_on_refine_search_results, filters}) end
      send(view.pid, {:assigns, on_refine_search_results: on_refine_search_results})

      view |> Components.RefineSearchResults.refine_results(%{"first_name" => " ", "city" => "Burlington"})

      assert_receive {:received_on_refine_search_results, filters}
      assert filters.city == "Burlington"
      refute Map.has_key?(filters, :first_name)
    end

    test "blank dob components are omitted", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestLiveView)

      pid = self()
      on_refine_search_results = fn filters -> send(pid, {:received_on_refine_search_results, filters}) end
      send(view.pid, {:assigns, on_refine_search_results: on_refine_search_results})

      view |> Components.RefineSearchResults.refine_results(%{"dob_year" => "", "dob_month" => "", "dob_day" => ""})

      assert_receive {:received_on_refine_search_results, filters}
      refute Map.has_key?(filters, :dob)

      view |> Components.RefineSearchResults.refine_results(%{"dob_year" => "1983", "dob_month" => "", "dob_day" => ""})
      assert_receive {:received_on_refine_search_results, filters}
      assert filters.dob == %{year: "1983"}

      view |> Components.RefineSearchResults.refine_results(%{"dob_year" => "", "dob_month" => "01", "dob_day" => ""})
      assert_receive {:received_on_refine_search_results, filters}
      assert filters.dob == %{month: "01"}

      view |> Components.RefineSearchResults.refine_results(%{"dob_year" => "", "dob_month" => "", "dob_day" => "31"})
      assert_receive {:received_on_refine_search_results, filters}
      assert filters.dob == %{day: "31"}
    end
  end
end
