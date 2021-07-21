defmodule EpiLocator.Search.PersonResultTest do
  use ExUnit.Case, async: true

  alias EpiLocator.Search.PersonResult

  test "person_dominant_values/1" do
    key = PersonResult.person_dominant_values_key()
    map = %{"some" => "map"}
    search_result = %{"DominantValues" => %{key => map}}
    assert PersonResult.person_dominant_values(search_result) == map
  end

  describe "new" do
    test "creates a person result from TR search results" do
      search_result = result_with_normal_values()

      person_result = PersonResult.new(search_result)

      assert person_result.first_name == "ERIC"
      assert person_result.middle_name == nil
      assert person_result.last_name == "Sample-Document"
      assert person_result.city == "SAN FRANCISCO"
      assert person_result.state == "CA"
      assert person_result.zip_code == "94102"
      assert person_result.street == "123 MARKET ST FL 3"
      assert person_result.reported_date == "09/15/2019"
      assert person_result.email_addresses == ["eric@starbucks.com"]
      assert person_result.dob == "06/XX/1984"
      assert person_result.id
      assert person_result.address == "123 MARKET ST FL 3, SAN FRANCISCO, CA 94102"
      assert person_result.address_hash

      [phone_number] = person_result.phone_numbers
      assert phone_number.phone == "(415) 123-4567"
      assert phone_number.source == ["Work Affiliations"]
    end

    test "turns empty maps and missing values into nils" do
      search_result = result_with_missing_values()

      person_result = PersonResult.new(search_result)

      assert person_result.first_name == "ERIC"
      assert person_result.middle_name == nil
      assert person_result.last_name == "Sample-Document"
      assert person_result.city == nil
      assert person_result.state == "CA"
      assert person_result.zip_code == "94102"
      assert person_result.street == nil
      assert person_result.reported_date == "09/15/2019"
      assert person_result.email_addresses == ["eric@starbucks.com"]
      assert person_result.dob == "Unavailable"
      assert person_result.id
      assert person_result.address == ", , CA 94102"
      assert person_result.address_hash

      [phone_number] = person_result.phone_numbers
      assert phone_number.phone == "(415) 123-4567"
      assert phone_number.source == ["Work Affiliations"]
    end

    test "works if there are multiple phones" do
      search_result = result_with_multiple_phone_numbers()

      person_result = PersonResult.new(search_result)

      assert person_result.first_name == "JOHN"
      assert person_result.middle_name == "R"
      assert person_result.last_name == "JONES"
      assert person_result.city == "KNOXVILLE"
      assert person_result.state == "TN"
      assert person_result.zip_code == "37932"
      assert person_result.street == "1234 FALL HAVEN LN"
      assert person_result.reported_date == "05/15/2020"
      assert person_result.email_addresses == []
      assert person_result.id
      assert person_result.address_hash

      [phone1, phone2] = person_result.phone_numbers

      assert phone1.phone == "(865) 247-5998"
      assert phone1.source == ["Experian", "Household Listing", "Phone Record", "Professional Licenses", "TransUnion"]

      assert phone2.phone == "(865) 323-0414"
      assert phone2.source == ["Phone Record"]
    end
  end

  test "handles multiple email addresses" do
    results =
      File.read!("test/fixtures/thomson-reuters/person-search-get-response.xml")
      |> XmlToMap.naive_map()
      |> Map.get("{http://clear.thomsonreuters.com/api/search/2.0}PersonResultsPage")
      |> Map.get("ResultGroup")

    person_result = PersonResult.new(results)

    assert person_result.first_name == "JANE"
    assert person_result.middle_name == nil
    assert person_result.last_name == "SAMPLE-DOCUMENT"
    assert person_result.city == "TUCSON"
    assert person_result.state == "AZ"
    assert person_result.zip_code == "85701"
    assert person_result.reported_date == "09/21/2019"
    assert person_result.street == "101 W 6th ST"
    assert person_result.id
    assert person_result.address_hash

    assert person_result.email_addresses == [
             "JANE.SAMPLE@TESCHMKT.COM",
             "JANE.SAMPLE@SBCGLOBAL.NET",
             "drsampledocument@janesampledocumentdds.com",
             "jane.sample@teschmkt.com",
             "john.sample-document@sample.com"
           ]

    [phone] = person_result.phone_numbers

    assert phone.phone == "(555) 555-0726"
    assert phone.source == ["Phone Record"]
  end

  defp result_with_normal_values do
    key = PersonResult.person_dominant_values_key()
    ns = PersonResult.namespace()

    %{
      "DominantValues" => %{
        key => %{
          "Address" => %{
            "City" => "SAN FRANCISCO",
            "State" => "CA",
            "Street" => "123 MARKET ST FL 3",
            "ZipCode" => "94102",
            "ReportedDate" => "09/15/2019"
          },
          "AgeInfo" => %{
            "PersonAge" => "36",
            "PersonBirthDate" => "06/XX/1984"
          },
          "Name" => %{
            "FirstName" => "ERIC",
            "FullName" => "ERIC Sample-Document",
            "LastName" => "Sample-Document"
          }
        }
      },
      "GroupId" => "000000007383fd710173989c99ec5461",
      "RecordCount" => "1",
      "RecordDetails" => %{
        "{#{ns}}PersonResponseDetail" => %{
          "AdditionalPhoneNumbers" => %{
            "PhoneNumber" => "(415) 123-4567",
            "SourceInfo" => %{
              "SourceDocumentGuid" => "I00000000828811e18b05fdf15589d8e8",
              "SourceName" => "Work Affiliations"
            }
          },
          "AllSourceDocuments" => %{
            "SourceDocumentGuid" => "I00000000828811e18b05fdf15589d8e8",
            "SourceName" => "Work Affiliations"
          },
          "EmailAddress" => "eric@starbucks.com",
          "Employer" => "STARBUCKS",
          "KnownAddresses" => %{
            "Address" => %{
              "City" => "SAN FRANCISCO",
              "Country" => "USA",
              "County" => "SAN FRANCISCO COUNTY",
              "Latitude" => "37.78687",
              "Longitude" => "-122.40446",
              "State" => "CA",
              "Street" => "123 MARKET ST FL 3",
              "ZipCode" => "94102"
            },
            "Phones" => %{"PhoneNumber" => "(415) 123-4567"},
            "SourceInfo" => %{
              "SourceDocumentGuid" => "I00000000828811e18b05fdf15589d8e8",
              "SourceName" => "Work Affiliations"
            }
          },
          "Message" => "Please Note: Limited information is available for this individual from the Work Affiliations record.",
          "Name" => %{
            "FirstName" => "ERIC",
            "FullName" => "ERIC Sample-Document",
            "LastName" => "Sample-Document"
          },
          "PersonEntityId" => "P2__LTgyMDcxMzQ3ODI",
          "PersonProfile" => %{}
        }
      },
      "Relevance" => "99"
    }
  end

  defp result_with_missing_values do
    key = PersonResult.person_dominant_values_key()
    ns = PersonResult.namespace()

    %{
      "DominantValues" => %{
        key => %{
          "Address" => %{
            "City" => %{},
            "State" => "CA",
            "Street" => nil,
            "ZipCode" => "94102",
            "ReportedDate" => "09/15/2019"
          },
          "Name" => %{
            "FirstName" => "ERIC",
            "FullName" => "ERIC Sample-Document",
            "LastName" => "Sample-Document"
          }
        }
      },
      "GroupId" => "000000007383fd710173989c99ec5461",
      "RecordCount" => "1",
      "RecordDetails" => %{
        "{#{ns}}PersonResponseDetail" => %{
          "AdditionalPhoneNumbers" => %{
            "PhoneNumber" => "(415) 123-4567",
            "SourceInfo" => %{
              "SourceDocumentGuid" => "I00000000828811e18b05fdf15589d8e8",
              "SourceName" => "Work Affiliations"
            }
          },
          "AllSourceDocuments" => %{
            "SourceDocumentGuid" => "I00000000828811e18b05fdf15589d8e8",
            "SourceName" => "Work Affiliations"
          },
          "EmailAddress" => "eric@starbucks.com",
          "Employer" => "STARBUCKS",
          "KnownAddresses" => %{
            "Address" => %{
              "City" => "SAN FRANCISCO",
              "Country" => "USA",
              "County" => "SAN FRANCISCO COUNTY",
              "Latitude" => "37.78687",
              "Longitude" => "-122.40446",
              "State" => "CA",
              "Street" => "123 MARKET ST FL 3",
              "ZipCode" => "94102"
            },
            "Phones" => %{"PhoneNumber" => "(415) 123-4567"},
            "SourceInfo" => %{
              "SourceDocumentGuid" => "I00000000828811e18b05fdf15589d8e8",
              "SourceName" => "Work Affiliations"
            }
          },
          "Message" => "Please Note: Limited information is available for this individual from the Work Affiliations record.",
          "Name" => %{
            "FirstName" => "ERIC",
            "FullName" => "ERIC Sample-Document",
            "LastName" => "Sample-Document"
          },
          "PersonEntityId" => "P2__LTgyMDcxMzQ3ODI",
          "PersonProfile" => %{}
        }
      },
      "Relevance" => "99"
    }
  end

  defp result_with_multiple_phone_numbers do
    key = PersonResult.person_dominant_values_key()
    ns = PersonResult.namespace()

    %{
      "DominantValues" => %{
        key => %{
          "Address" => %{
            "City" => "KNOXVILLE",
            "ReportedDate" => "05/15/2020",
            "State" => "TN",
            "Street" => "1234 FALL HAVEN LN",
            "ZipCode" => "37932"
          },
          "AgeInfo" => %{
            "PersonAge" => "36",
            "PersonBirthDate" => "06/XX/1984"
          },
          "Name" => %{
            "FirstName" => "JOHN",
            "FullName" => "JONES, JOHN R",
            "LastName" => "JONES",
            "MiddleName" => "R"
          },
          "SSN" => "259-81-XXXX"
        }
      },
      "GroupId" => "000000007383fd710173989c99ef5463",
      "RecordCount" => "1",
      "RecordDetails" => %{
        "{#{ns}}PersonResponseDetail" => %{
          "AdditionalPhoneNumbers" => [
            %{
              "PhoneNumber" => "(865) 247-5998",
              "SourceInfo" => [
                %{
                  "SourceDocumentGuid" => "I00000000942211e598dc8b09b4f043e0",
                  "SourceName" => "Phone Record"
                },
                %{
                  "SourceDocumentGuid" => "I000000009fe511eabea3f0dc9fb69570",
                  "SourceName" => "Phone Record"
                },
                %{
                  "SourceDocumentGuid" => "I00000000802d11e28578f7ccc38dcbee",
                  "SourceName" => "Household Listing"
                },
                %{
                  "SourceDocumentGuid" => "I00000000274211ddb862ead008c6b935",
                  "SourceName" => "Experian"
                },
                %{
                  "SourceDocumentGuid" => "I00000000444411e698dc8b09b4f043e0",
                  "SourceName" => "TransUnion"
                },
                %{
                  "SourceDocumentGuid" => "I00000000553611e89bf199c0ee06c731",
                  "SourceName" => "TransUnion"
                },
                %{
                  "SourceDocumentGuid" => "I00000000b72811de9b8c850332338889",
                  "SourceName" => "Professional Licenses"
                }
              ]
            },
            %{
              "PhoneNumber" => "(865) 323-0414",
              "SourceInfo" => %{
                "SourceDocumentGuid" => "I00000000c9b111e398db8b09b4f043e0",
                "SourceName" => "Phone Record"
              }
            }
          ]
        }
      }
    }
  end
end
