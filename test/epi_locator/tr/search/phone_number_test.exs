defmodule EpiLocator.Search.PhoneNumberTest do
  use ExUnit.Case, async: true

  alias EpiLocator.Search.PhoneNumber

  describe "new" do
    test "creates a phone result from TR search AdditionalPhoneNumber" do
      search_result = %{
        "PhoneNumber" => "(415) 123-4567",
        "SourceInfo" => %{
          "SourceDocumentGuid" => "I00000000828811e18b05fdf15589d8e8",
          "SourceName" => "Work Affiliations"
        }
      }

      phone_number = PhoneNumber.new(search_result)

      assert phone_number.phone == "(415) 123-4567"
      assert phone_number.source == ["Work Affiliations"]
      assert phone_number.id
    end
  end

  test "records multiple sources" do
    search_result = %{
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
    }

    phone_number = PhoneNumber.new(search_result)

    assert phone_number.phone == "(865) 247-5998"
    assert phone_number.source == ["Experian", "Household Listing", "Phone Record", "Professional Licenses", "TransUnion"]
    assert phone_number.id
  end
end
