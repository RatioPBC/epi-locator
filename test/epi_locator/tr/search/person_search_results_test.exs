defmodule EpiLocator.Search.PersonSearchResultsTest do
  use ExUnit.Case, async: true

  alias EpiLocator.Search.PersonSearchResults

  describe "new" do
    test "creates phone results from TR search results - one result" do
      results = PersonSearchResults.new(one_result())
      [person_result] = results

      assert person_result.first_name == "JANE"
      assert person_result.middle_name == nil
      assert person_result.last_name == "SAMPLE-DOCUMENT"
      assert person_result.city == "TUCSON"
      assert person_result.zip_code == "85701"
      assert person_result.street == "101 W 6th ST"
      assert person_result.state == "AZ"
      assert person_result.reported_date == "09/21/2019"

      [phone_number] = person_result.phone_numbers
      assert phone_number.phone == "(555) 555-0726"
      assert phone_number.source == ["Phone Record"]
    end

    test "creates phone results from TR search results - two results" do
      results = PersonSearchResults.new(two_results())
      [person_result1, person_result2] = results

      assert person_result1.first_name == "JOHN"
      assert person_result1.middle_name == nil
      assert person_result1.last_name == "DOE"
      assert person_result1.city == "SAN FRANCISCO"
      assert person_result1.zip_code == "94103"
      assert person_result1.street == "123 MARKET ST FL 3"
      assert person_result1.state == "CA"
      assert person_result1.reported_date == nil

      [phone_number] = person_result1.phone_numbers
      assert phone_number.phone == "(415) 123-4567"
      assert phone_number.source == ["Work Affiliations"]
      # -------------
      assert person_result2.first_name == "JOHN"
      assert person_result2.middle_name == nil
      assert person_result2.last_name == "DOE"
      assert person_result2.city == "SAN FRANCISCO"
      assert person_result2.zip_code == "94127"
      assert person_result2.street == "12 ROCKAWAY AVE"
      assert person_result2.state == "CA"
      assert person_result2.reported_date == "10/14/2018"

      [phone1, phone2] = person_result2.phone_numbers

      assert phone1.phone == "(415) 731-5432"
      assert phone1.source == ["Household Listing", "Phone Record", "TransUnion", "Utility Listing"]

      assert phone2.phone == "(415) 987-6543"
      assert phone2.source == ["Phone Record", "Utility Listing"]
    end
  end

  def one_result, do: read_xml_and_turn_into_map("test/fixtures/thomson-reuters/person-search-get-response.xml")

  def two_results, do: read_xml_and_turn_into_map("test/fixtures/thomson-reuters/person-search-get-response_two-results.xml")

  def read_xml_and_turn_into_map(filename) do
    filename |> File.read!() |> XmlToMap.naive_map() |> Map.get("{http://clear.thomsonreuters.com/api/search/2.0}PersonResultsPage")
  end
end
