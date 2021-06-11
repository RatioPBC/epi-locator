defmodule EpiLocator.Search.PhoneResultTest do
  use ExUnit.Case, async: true

  alias EpiLocator.Search.PhoneResult

  describe "new" do
    test "creates a phone result from TR search results" do
      search_result = %{
        "DominantValues" => %{
          "PhoneDominantValues" => %{
            "Address" => %{
              "City" => "Anytown",
              "State" => "CA",
              "Street" => "123 MAIN STREET",
              "ZipCode" => "12345"
            },
            "Name" => "SMITH, SAM",
            "PhoneNumber" => "(630) 123-4567",
            "ReportedDate" => "04/15/2020"
          }
        },
        "GroupId" => "00000000733c12ed01735f0ca6516ce3",
        "RecordCount" => "1",
        "RecordDetails" => %{
          "PhoneResponseDetail" => %{
            "DocumentGuids" => %{
              "SourceDocumentGuid" => "I00000000708b11e79bef99c0ee06c731",
              "SourceName" => "Phone Record"
            },
            "PhoneRecord" => %{
              "Address" => %{},
              "FirstReportedDate" => "07/01/2002",
              "LastReportedDate" => "04/15/2020",
              "ListedInDirectoryAssist" => "YES",
              "MailDeliverable" => "YES",
              "Name" => "SMITH, SAM",
              "OriginalServiceProvider" => "PACIFIC BELL",
              "PhoneConfidenceScore" => "DAILY VALIDATION",
              "PhoneNumber" => "(630) 123-4567",
              "PhoneType" => "LAND LINE",
              "RecordType" => "RESIDENTIAL",
              "Source" => "Phone Record"
            }
          }
        },
        "Relevance" => "99"
      }

      phone_result = PhoneResult.new(search_result)

      assert phone_result.phone_number == "(630) 123-4567"
      assert phone_result.city == "Anytown"
      assert phone_result.state == "CA"
      assert phone_result.zip_code == "12345"
      assert phone_result.street == "123 MAIN STREET"
    end

    test "turns empty maps and missing values into nils" do
      search_results = %{
        "DominantValues" => %{
          "PhoneDominantValues" => %{
            "Address" => %{"Street" => %{}},
            "Name" => "SAMPLE-DOCUMENT, ERIC FULL",
            "PhoneNumber" => "(612) 555-8910",
            "ReportedDate" => "07/16/2020"
          }
        },
        "Relevance" => "99"
      }

      phone_result = PhoneResult.new(search_results)

      assert phone_result.phone_number == "(612) 555-8910"
      assert phone_result.city == nil
      assert phone_result.state == nil
      assert phone_result.zip_code == nil
      assert phone_result.street == nil
    end
  end
end
