defmodule EpiLocatorWeb.Acceptance.SearchTest do
  use EpiLocatorWeb.AcceptanceCase, async: false

  alias EpiLocator.Accounts.UserToken
  alias EpiLocator.HTTPoisonMock
  alias EpiLocator.Repo

  import Mox
  alias Wallaby.Browser

  setup :set_mox_global
  setup :verify_on_exit!

  #  @name "Test JME3"
  @case_id "00000000-8434-4475-b111-bb3a902b398b"
  @domain "ny-state-covid19"
  @user_id "00000000341443b88624452b53fa42fb"

  @commcare_user_url "https://www.commcarehq.org/a/ny-state-covid19/api/v0.5/user/00000000341443b88624452b53fa42fb/?format=json"

  @expected_headers ["content-type": "application/xml", Authorization: "Basic faked-base64-encoded-basic-auth"]
  @expected_person_search_url "https://s2s.beta.thomsonreuters.com/api/v2/person/searchResults"

  # From the value inside of: test/fixtures/thomson-reuters/phone-search-post-response.xml:
  @expected_url_for_results "https://s2s.beta.thomsonreuters.com/api/v2/person/searchResults/00000000733671e20173494ef23b34b5"

  describe "when the user is NOT logged into epi-locator" do
    test "they are redirected to root index and flashed that they are not allowed to log in", %{session: session} do
      mox_expectations_for_commcare_GET(0)
      mox_expectation_for_tr_person_search_POST(0)
      mox_expectation_for_tr_person_search_results_GET(0)

      assert Repo.all(UserToken) |> length() == 0

      session =
        session
        |> visit("/search?case-id=#{@case_id}&domain=#{@domain}&user-id=#{@user_id}")
        |> assert_has(css("p", text: "You must log in to access this page."))

      assert Browser.current_path(session) == "/access-denied"
    end
  end

  # TODO make this pass with a verify with appropriate body and signature
  @tag :skip
  describe "when the user is logged into epi-locator" do
    feature "they visit /verify, receive a cookie, visit /search, and read from TR", %{session: session} do
      expect(EpiLocator.SignatureMock, :valid?, fn _ ->
        true
      end)

      mox_expectations_for_commcare_GET(1)
      mox_expectation_for_tr_person_search_POST(1)
      mox_expectation_for_tr_person_search_results_GET(1)

      assert Repo.all(UserToken) |> length() == 0

      session =
        session
        |> visit("/search?case-id=#{@case_id}&domain=#{@domain}&user-id=#{@user_id}")
        |> assert_has(css("p", text: "You must log in to access this page."))

      assert Browser.current_path(session) == "/"

      session =
        session
        # TODO add signature and POST body
        |> visit("/verify")

      # TODO check that the cookie is set, or something, basically that they are successfully "logged in"
      # TODO or don't, because you can prove it's true by visiting /search successfully.

      session
      |> visit("/search?case-id=#{@case_id}&domain=#{@domain}&user-id=#{@user_id}")
      |> assert_has(css("h1", text: "Epi Locator"))
      |> assert_has(css("span", text: "05/30/1987"))
      |> assert_has(css("h3", text: "Test JME3"))
      |> assert_has(css("h4", text: "12 Main st"))
      |> assert_has(css("h4", text: "Test"))
      |> assert_has(css("h4", text: "NY"))
      |> assert_has(css("h4", text: "12831"))
      |> assert_has(css("h4", text: "4544454555"))
      |> assert_has(css("h5", text: "1 result"))
      |> assert_has(css(".phone-number", text: "(555) 555-0726"))
    end
  end

  # credo:disable-for-next-line Credo.Check.Readability.FunctionNames
  defp mox_expectations_for_commcare_GET(n) do
    expect(HTTPoisonMock, :get, n, fn url, header ->
      assert header == [{:Authorization, "ApiKey johndoe@example.com:0000000060a6f9e4f46a069c2691083010cbb57d"}]

      response_json =
        if url == @commcare_user_url do
          File.read!("test/fixtures/commcare/00000000341443b88624452b53fa42fb.json")
        else
          File.read!("test/fixtures/commcare/case-with-test-results-and-contacts.json")
        end

      {:ok, %HTTPoison.Response{status_code: 200, body: response_json}}
    end)
  end

  # credo:disable-for-next-line Credo.Check.Readability.FunctionNames
  defp mox_expectation_for_tr_person_search_POST(n) do
    expect(HTTPoisonMock, :post, n, fn url, _body, headers, _http_options ->
      assert headers == @expected_headers
      assert url == @expected_person_search_url
      response_body = File.read!("test/fixtures/thomson-reuters/person-search-post-response.xml")
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}}
    end)
  end

  # credo:disable-for-next-line Credo.Check.Readability.FunctionNames
  def mox_expectation_for_tr_person_search_results_GET(n) do
    expect(HTTPoisonMock, :get, n, fn url, headers, _http_options ->
      assert headers == @expected_headers
      assert url == @expected_url_for_results
      response_body = File.read!("test/fixtures/thomson-reuters/person-search-get-response.xml")
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}}
    end)
  end
end
