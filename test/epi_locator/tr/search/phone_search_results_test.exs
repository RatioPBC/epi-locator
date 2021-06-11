defmodule EpiLocator.Search.PhoneSearchResultsTest do
  use ExUnit.Case, async: true

  alias EpiLocator.Search.PhoneSearchResults

  describe "new" do
    test "creates phone results from TR search results - one result" do
      [phone_result] = PhoneSearchResults.new(one_result())

      assert phone_result.phone_number == "(630) 123-4567"
      assert phone_result.city == "Anytown"
      assert phone_result.state == "CA"
      assert phone_result.zip_code == "12345"
      assert phone_result.street == "123 MAIN STREET"
    end

    test "creates phone results from TR search results - multiple results" do
      [phone_result1, phone_result2] = PhoneSearchResults.new(two_results())

      assert phone_result1.phone_number == "(206) 222-2222"
      assert phone_result1.city == "SEATTLE"
      assert phone_result1.state == "WA"
      assert phone_result1.zip_code == "98111"
      assert phone_result1.street == "1234 UNION AVE N"

      assert phone_result2.phone_number == "(206) 333-3333"
      assert phone_result2.city == "BROOKLYN"
      assert phone_result2.state == "NY"
      assert phone_result2.zip_code == "11201"
      assert phone_result2.street == "111 SPENCER ST A9"
    end
  end

  def one_result do
    %{
      "EndIndex" => "0",
      "ResultGroup" => %{
        "DominantValues" => %{
          "PhoneDominantValues" => %{
            "Address" => %{
              "City" => "Anytown",
              "State" => "CA",
              "Street" => "123 MAIN STREET",
              "ZipCode" => "12345"
            },
            "Name" => "SAMPLE-DOCUMENT, ERIC FULL",
            "PhoneNumber" => "(630) 123-4567",
            "ReportedDate" => "11/13/2000"
          }
        },
        "GroupId" => "00000000733c12ed01735f18d011537e",
        "RecordCount" => "1",
        "RecordDetails" => %{
          "PhoneResponseDetail" => %{
            "DocumentGuids" => %{
              "SourceDocumentGuid" => "I000000000fe511e3a86490b11c6a4a8f",
              "SourceName" => "TransUnion Record"
            },
            "TransUnionRecord" => %{
              "AKAName" => %{
                "FullName" => ["ERIC \"BUBBA\" SAMPLE-DOCUMENT", "SAMPLE-DOCUMENT, ERIC", "E.F. SAMPLE-DOCUMENT", "ERIC F. SAMPLE-DOCUMENT"]
              },
              "AddressesPhones" => [
                %{
                  "Address" => %{
                    "City" => "EAGAN",
                    "State" => "MN",
                    "Street" => "4010 CINNABAR DRIVE",
                    "ZipCode" => "55122",
                    "ZipCodeExtension" => "1234"
                  },
                  "PhoneNumber1" => "(612) 555-4567",
                  "PhoneNumber2" => "(612) 555-8910",
                  "ReportedDate" => "11/13/2000"
                },
                %{
                  "Address" => %{
                    "City" => "EAGAN",
                    "State" => "MN",
                    "Street" => "4012 CINNABAR DRIVE",
                    "ZipCode" => "55122",
                    "ZipCodeExtension" => "1234"
                  },
                  "PhoneNumber1" => "(651) 555-9999",
                  "ReportedDate" => "07/01/2000"
                },
                %{
                  "Address" => %{
                    "City" => "EAGAN",
                    "State" => "MN",
                    "Street" => "4000 CINNABAR DRIVE",
                    "ZipCode" => "55122",
                    "ZipCodeExtension" => "1234"
                  },
                  "PhoneNumber1" => "(612) 555-1234",
                  "PhoneNumber2" => "(612) 555-0000",
                  "ReportedDate" => "03/02/1999"
                }
              ],
              "HistoricPhoneNumber" => "555-4567",
              "NameFirstReported" => "11/01/1985",
              "PersonName" => %{
                "FirstName" => "ERIC",
                "LastName" => "SAMPLE-DOCUMENT",
                "MiddleName" => "FULL",
                "Prefix" => "DR",
                "Suffix" => "JR"
              },
              "Source" => "TransUnion Record"
            }
          }
        },
        "Relevance" => "99"
      },
      "StartIndex" => "0",
      "Status" => %{"StatusCode" => "200", "SubStatusCode" => "200"}
    }
  end

  def two_results do
    %{
      "EndIndex" => "1",
      "ResultGroup" => [
        %{
          "DominantValues" => %{
            "PhoneDominantValues" => %{
              "Address" => %{
                "City" => "SEATTLE",
                "State" => "WA",
                "Street" => "1234 UNION AVE N",
                "ZipCode" => "98111"
              },
              "Name" => "JONES, JIM",
              "PhoneNumber" => "(206) 222-2222",
              "ReportedDate" => "01/01/2015"
            }
          },
          "GroupId" => "00000000733c12ed01735f9a48af68c4",
          "RecordCount" => "1",
          "RecordDetails" => %{
            "PhoneResponseDetail" => %{
              "DocumentGuids" => %{
                "SourceDocumentGuid" => "I00000000ca7511e398db8b09b4f043e0",
                "SourceName" => "Phone Record"
              },
              "PhoneRecord" => %{
                "Address" => %{},
                "FirstReportedDate" => "08/23/2010",
                "LastReportedDate" => "10/13/2019",
                "MailDeliverable" => "YES",
                "Name" => "JONES, JIM",
                "OriginalServiceProvider" => "T-MOBILE USA, INC.",
                "PhoneConfidenceScore" => "PRIVATE NUMBER VALIDATED WITHIN PAST 12-18 MONTHS",
                "PhoneNumber" => "(206) 222-2222",
                "PhoneType" => "WIRELESS",
                "RecordType" => "RESIDENTIAL",
                "Source" => "Phone Record"
              }
            }
          },
          "Relevance" => "99"
        },
        %{
          "DominantValues" => %{
            "PhoneDominantValues" => %{
              "Address" => %{
                "City" => "BROOKLYN",
                "State" => "NY",
                "Street" => "111 SPENCER ST A9",
                "ZipCode" => "11201"
              },
              "Name" => "JONES, JIM",
              "PhoneNumber" => "(206) 333-3333",
              "ReportedDate" => "04/30/2020"
            }
          },
          "GroupId" => "00000000733c12ed01735f9a48b168c5",
          "RecordCount" => "1",
          "RecordDetails" => %{
            "PhoneResponseDetail" => %{
              "DocumentGuids" => %{
                "SourceDocumentGuid" => "I00000000b3f911da8556b880b93a2fcd",
                "SourceName" => "TransUnion Record"
              },
              "TransUnionRecord" => %{
                "AKAName" => %{"FullName" => "JONES, JIM"},
                "AddressesPhones" => [
                  %{
                    "Address" => %{
                      "City" => "BROOKLYN",
                      "State" => "NY",
                      "Street" => "111 SPENCER ST A9",
                      "ZipCode" => "11201",
                      "ZipCodeExtension" => "4583"
                    },
                    "PhoneNumber1" => "(206) 333-3333",
                    "ReportedDate" => "04/30/2020"
                  }
                ],
                "NameFirstReported" => "12/22/2005",
                "PersonAge" => "36",
                "PersonBirthDate" => "06/XX/1984",
                "PersonName" => %{"FirstName" => "JIM", "LastName" => "JONES"},
                "Source" => "TransUnion Record"
              }
            }
          },
          "Relevance" => "99"
        }
      ],
      "StartIndex" => "0",
      "Status" => %{"StatusCode" => "200", "SubStatusCode" => "200"}
    }
  end
end
