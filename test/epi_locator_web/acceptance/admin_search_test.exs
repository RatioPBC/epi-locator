defmodule EpiLocatorWeb.Acceptance.AdminSearchTest do
  use EpiLocatorWeb.AcceptanceCase, async: false
  import EpiLocator.AccountsFixtures

  import Mox

  setup :set_mox_global
  setup :verify_on_exit!
  setup :tr_enabled

  @expected_phone_search_url "https://s2s.beta.thomsonreuters.com/api/v2/phone/searchResults"
  @expected_person_search_url "https://s2s.beta.thomsonreuters.com/api/v2/person/searchResults"

  describe "phone search" do
    setup do
      Mox.stub(TRClientBehaviourMock, :phone_search, fn _ ->
        {:ok, @expected_phone_search_url}
      end)

      Mox.stub(TRClientBehaviourMock, :phone_search_results, fn _ ->
        raw_body = File.read!("test/fixtures/thomson-reuters/phone-search-get-response.xml")
        key = "{http://clear.thomsonreuters.com/api/search/2.0}PhoneResultsPage"
        phone_results = raw_body |> XmlToMap.naive_map() |> Map.get(key)
        {:ok, phone_results}
      end)

      :ok
    end

    feature "they can do a phone search against Thomson Reuters", %{session: session} do
      session =
        session
        |> log_in()
        |> visit("http://localhost:4002/private/search")
        |> assert_has(css("h1", text: "Thomson Reuters Search"))
        |> assert_empty_search_fields()
        |> fill_in_search_fields()
        |> click(css("#phone-search"))
        |> click(css("#submit"))

      # Do something better than sleep here!
      :timer.sleep(300)

      session
      |> assert_value("#first-name", "Eric")
      |> assert_value("#last-name", "Sample-Document")
      |> assert_value("#street", "4010 Cinnabar Drive")
      |> assert_value("#city", "Eagan")
      |> assert_value("#state", "MN")
      |> assert_value("#zip-code", "55122")
      |> assert_value("#phone", "612-555-8910")
      |> assert_value("#dob", "10/1/1980")
      # ----------
      |> assert_has(css("h5", text: "1 result"))
      |> assert_has(css(".phone-number", text: "(651) 555-9999"))

      session
      |> click(css("#clear-form"))
      |> assert_empty_search_fields()
    end
  end

  describe "person search" do
    setup do
      Mox.stub(TRClientBehaviourMock, :person_search, fn _ ->
        {:ok, @expected_person_search_url}
      end)

      Mox.stub(TRClientBehaviourMock, :person_search_results, fn _ ->
        raw_body = File.read!("test/fixtures/thomson-reuters/person-search-get-response.xml")
        key = "{http://clear.thomsonreuters.com/api/search/2.0}PersonResultsPage"
        phone_results = raw_body |> XmlToMap.naive_map() |> Map.get(key)
        {:ok, phone_results}
      end)

      :ok
    end

    feature "they can do a person search against Thomson Reuters", %{session: session} do
      session =
        session
        |> log_in()
        |> visit("http://localhost:4002/private/search")
        |> assert_has(css("h1", text: "Thomson Reuters Search"))
        |> assert_empty_search_fields()
        |> fill_in_search_fields()
        |> click(css("#person-search"))
        |> click(css("#submit"))

      # Do something better than sleep here!
      :timer.sleep(500)

      session
      |> assert_value("#first-name", "Eric")
      |> assert_value("#last-name", "Sample-Document")
      |> assert_value("#street", "4010 Cinnabar Drive")
      |> assert_value("#city", "Eagan")
      |> assert_value("#state", "MN")
      |> assert_value("#zip-code", "55122")
      |> assert_value("#phone", "612-555-8910")
      |> assert_value("#dob", "10/1/1980")
      # ----------
      |> assert_has(css("h5", text: "1 result"))
      |> assert_has(css(".phone-number", text: "(555) 555-0726"))

      session
      |> click(css("#clear-form"))
      |> assert_empty_search_fields()
    end
  end

  describe "when no search results are returned" do
    setup do
      Mox.stub(TRClientBehaviourMock, :phone_search, fn _ ->
        {:error, "no search results URL returned from Thomson Reuters"}
      end)

      :ok
    end

    feature "the user sees an error message that there are no TR search results", %{session: session} do
      session =
        session
        |> log_in()
        |> visit("http://localhost:4002/private/search")
        |> assert_has(css("h1", text: "Thomson Reuters Search"))
        |> fill_in_search_fields()
        |> click(css("#phone-search"))
        |> click(css("#submit"))

      # Do something better than sleep here!
      :timer.sleep(300)

      session
      |> assert_has(css("h2", text: "No results found"))
    end
  end

  defp fill_in_search_fields(session) do
    session
    |> set_value(css("input#first-name"), "Eric")
    |> set_value(css("input#last-name"), "Sample-Document")
    |> set_value(css("input#street"), "4010 Cinnabar Drive")
    |> set_value(css("input#city"), "Eagan")
    |> set_value(css("select#state"), "Minnesota")
    |> set_value(css("input#zip-code"), "55122")
    |> set_value(css("input#phone"), "612-555-8910")
    |> set_value(css("input#dob"), "10/1/1980")
  end

  defp assert_empty_search_fields(session) do
    session
    |> assert_value("#first-name", "")
    |> assert_value("#last-name", "")
    |> assert_value("#street", "")
    |> assert_value("#city", "")
    |> assert_value("#state", "")
    |> assert_value("#zip-code", "")
    |> assert_value("#phone", "")
    |> assert_value("#dob", "")
  end

  defp log_in(session, admin \\ admin_fixture(), password \\ valid_admin_password()) do
    session
    |> visit("/admins/log_in")
    |> set_value(css("input[name='admin[email]']"), admin.email)
    |> set_value(css("input[name='admin[password]']"), password)
    |> set_value(css("input[name='admin[verification_code]']"), verification_code(admin.totp_secret))
    |> click(css("button[type=submit]"))
  end

  def assert_value(session, css_selector, expected_value) do
    assert session |> find(css(css_selector)) |> Element.value() == expected_value
    session
  end

  defp tr_enabled(context) do
    {:ok, true} = FunWithFlags.enable(EpiLocator.TRClient.flag_name())

    {:ok, context}
  end
end
