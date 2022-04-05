defmodule EpiLocator.TrApiTest do
  use EpiLocator.DataCase, async: false

  import Mox

  alias EpiLocator.Search.PersonResult
  alias EpiLocator.TrApi

  setup :set_mox_global
  setup :verify_on_exit!

  describe "lookup_person" do
    test "passes through errors from a person search" do
      expect(TRClientBehaviourMock, :person_search, fn _person_data -> :error_in_person_search end)

      assert :error_in_person_search = TrApi.lookup_person(%{})
    end

    test "passes through errors from a person search results" do
      stub(TRClientBehaviourMock, :person_search, fn _person_data -> {:ok, :person_search_result_url} end)
      expect(TRClientBehaviourMock, :person_search_results, fn :person_search_result_url -> :error_in_person_search_results end)

      assert :error_in_person_search_results = TrApi.lookup_person(%{})
    end

    test "returns a success tuple with results as a parsed data object" do
      stub(TRClientBehaviourMock, :person_search, fn _person_data -> {:ok, :person_search_result_url} end)

      stub(TRClientBehaviourMock, :person_search_results, fn :person_search_result_url ->
        results =
          "test/fixtures/thomson-reuters/person-search-get-response.xml"
          |> File.read!()
          |> XmlToMap.naive_map()
          |> Map.get("{http://clear.thomsonreuters.com/api/search/2.0}PersonResultsPageV3")

        {:ok, results}
      end)

      assert {:ok, results} = TrApi.lookup_person(%{})
      assert [%PersonResult{first_name: "JANE"} | _rest] = results
    end

    test "uses the passed person data to search" do
      person_data = %{name: "Fixture Person"}

      expect(TRClientBehaviourMock, :person_search, fn ^person_data -> {:ok, :person_search_result_url} end)

      stub(TRClientBehaviourMock, :person_search_results, fn :person_search_result_url ->
        results =
          "test/fixtures/thomson-reuters/person-search-get-response.xml"
          |> File.read!()
          |> XmlToMap.naive_map()
          |> Map.get("{http://clear.thomsonreuters.com/api/search/2.0}PersonResultsPageV3")

        {:ok, results}
      end)

      TrApi.lookup_person(person_data)
    end
  end
end
