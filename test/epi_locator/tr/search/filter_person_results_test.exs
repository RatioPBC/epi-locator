defmodule EpiLocator.Search.FilterPersonResultsTest do
  use ExUnit.Case, async: true

  alias EpiLocator.Search.FilterPersonResults
  alias EpiLocator.Search.PersonResult
  alias EpiLocator.Search.PhoneNumber

  describe "filtering by nothing" do
    setup do
      person_results = [
        %PersonResult{
          city: "City",
          email_addresses: ["john@example.com"],
          first_name: "JOHN1",
          last_name: "Lastname",
          middle_name: nil,
          phone_numbers: [
            %PhoneNumber{
              phone: "(415) 123-4560",
              source: ["Work Affiliations"]
            }
          ],
          reported_date: nil,
          state: "NY",
          street: "123 MARKET ST FL 3",
          zip_code: "94103"
        },
        %PersonResult{
          city: "City",
          email_addresses: ["john@example.com"],
          first_name: "JOHN2",
          last_name: "Lastname",
          middle_name: nil,
          phone_numbers: [
            %PhoneNumber{
              phone: "(415) 123-4560",
              source: ["Work Affiliations"]
            }
          ],
          reported_date: nil,
          state: "NY",
          street: "123 MARKET ST FL 3",
          zip_code: "94103"
        }
      ]

      [person_results: person_results]
    end

    test "returns all results", %{person_results: person_results} do
      assert [%{first_name: "JOHN1"}, %{first_name: "JOHN2"}] = FilterPersonResults.filter(person_results, %{})
    end
  end

  describe "filtering by a single regular property" do
    setup do
      person_results = [
        %PersonResult{
          city: "City",
          email_addresses: ["john@example.com"],
          first_name: "JOHN1",
          last_name: "Lastname",
          middle_name: nil,
          phone_numbers: [
            %PhoneNumber{
              phone: "(415) 123-4560",
              source: ["Work Affiliations"]
            }
          ],
          reported_date: nil,
          state: "NY",
          street: "123 MARKET ST FL 3",
          zip_code: "94103"
        },
        %PersonResult{
          city: "City",
          email_addresses: ["john@example.com"],
          first_name: "JOHN2",
          last_name: "Lastname",
          middle_name: nil,
          phone_numbers: [
            %PhoneNumber{
              phone: "(415) 123-4560",
              source: ["Work Affiliations"]
            }
          ],
          reported_date: nil,
          state: "NY",
          street: "123 MARKET ST FL 3",
          zip_code: "94103"
        }
      ]

      [person_results: person_results]
    end

    test "returns results that match the given property", %{person_results: person_results} do
      filtered_results = FilterPersonResults.filter(person_results, %{first_name: "JOHN1"})

      assert [john] = filtered_results
      assert john.first_name == "JOHN1"
    end

    test "returns results that match the given property with different casing", %{person_results: person_results} do
      filtered_results = FilterPersonResults.filter(person_results, %{first_name: "jOhN1"})

      assert [john] = filtered_results
      assert john.first_name == "JOHN1"
    end

    test "returns results that match the start of the given property", %{person_results: person_results} do
      filtered_results = FilterPersonResults.filter(person_results, %{first_name: "jO"})

      assert [john1, john2] = filtered_results
      assert john1.first_name == "JOHN1"
      assert john2.first_name == "JOHN2"

      filtered_results = FilterPersonResults.filter(person_results, %{first_name: "OHN1"})
      assert [] = filtered_results
    end
  end

  describe "filtering by phone" do
    test "returns results that match the given phone number" do
      person_results = [
        make_person(phone: "4151112222", first_name: "matching"),
        make_person(phone: "3331112222", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{phone: "4151112222"})
    end

    test "ignores non-numeric characters in the filter" do
      person_results = [
        make_person(phone: "4151112222", first_name: "matching"),
        make_person(phone: "3331112222", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{phone: " (415) 111-2222 "})
    end

    test "ignores non-numeric characters in the phone" do
      person_results = [
        make_person(phone: " (415) 111-2222 ", first_name: "matching"),
        make_person(phone: "3331112222", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{phone: "4151112222"})
    end

    test "ignores a leading one in the filter" do
      person_results = [
        make_person(phone: "4151112222 ", first_name: "matching"),
        make_person(phone: "3331112222", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{phone: "14151112222"})
    end

    test "ignores a leading one in the phone" do
      person_results = [
        make_person(phone: "14151112222 ", first_name: "matching"),
        make_person(phone: "3331112222", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{phone: "4151112222"})
    end

    test "ignores leading ones and non-numeric characters in both places" do
      person_results = [
        make_person(phone: "+1 (415) 111-2222 ", first_name: "matching"),
        make_person(phone: "3331112222", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{phone: "4151112222"})

      person_results = [
        make_person(phone: "4151112222", first_name: "matching"),
        make_person(phone: "3331112222", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{phone: "+1 (415) 111-2222 "})
    end

    test "handles nils in the phone" do
      person_results = [
        make_person(phone: " (415) 111-2222 ", first_name: "matching"),
        make_person(phone: nil, first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{phone: "4151112222"})
    end

    test "returns results that match the start of the given property" do
      person_results = [
        make_person(phone: " (415) 111-2222 ", first_name: "matching"),
        make_person(phone: "1415", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{phone: "14151"})
    end
  end

  describe "filtering by date of birth" do
    test "returns results that match the given date of birth exactly" do
      person_results = [
        make_person(dob: "02/03/2001", first_name: "matching"),
        make_person(dob: "05/07/2004", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{dob: %{year: "2001", month: "02", day: "03"}})
    end

    test "returns results that match the given date via masked values" do
      person_results = [
        make_person(dob: "XX/03/2001", first_name: "masked month"),
        make_person(dob: "XX/07/2004", first_name: "not-matching masked month"),
        make_person(dob: "02/XX/2001", first_name: "masked day"),
        make_person(dob: "05/XX/2004", first_name: "not-matching masked day"),
        make_person(dob: "02/03/XXXX", first_name: "masked year"),
        make_person(dob: "05/07/XXXX", first_name: "not-matching masked year"),
        make_person(dob: "XX/XX/XXXX", first_name: "masked everything"),
        make_person(dob: "05/07/2004", first_name: "not-matching")
      ]

      assert [
               %{first_name: "masked month"},
               %{first_name: "masked day"},
               %{first_name: "masked year"},
               %{first_name: "masked everything"}
             ] = FilterPersonResults.filter(person_results, %{dob: %{year: "2001", month: "02", day: "03"}})
    end

    test "returns results that match the given date when TR only has a year" do
      person_results = [
        make_person(dob: "2001", first_name: "matching"),
        make_person(dob: "05/07/2004", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{dob: %{year: "2001", month: "02", day: "03"}})
    end

    test "returns results that match the given date when TR only has a year and month" do
      person_results = [
        make_person(dob: "02/2001", first_name: "matching"),
        make_person(dob: "05/07/2004", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{dob: %{year: "2001", month: "02", day: "03"}})
    end

    test "allows matching by year alone" do
      person_results = [
        make_person(dob: "02/03/2001", first_name: "matching"),
        make_person(dob: "05/07/2004", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{dob: %{year: "2001"}})
    end

    test "allows matching by month alone" do
      person_results = [
        make_person(dob: "02/03/2001", first_name: "matching"),
        make_person(dob: "05/07/2004", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{dob: %{month: "02"}})
    end

    test "allows matching by day alone" do
      person_results = [
        make_person(dob: "02/03/2001", first_name: "matching"),
        make_person(dob: "05/07/2004", first_name: "not-matching")
      ]

      assert [%{first_name: "matching"}] = FilterPersonResults.filter(person_results, %{dob: %{day: "03"}})
    end

    test "handles people that lack a date of birth in their TR result" do
      person_results = [
        make_person(dob: PersonResult.unavailable_dob_string(), first_name: "not-matching")
      ]

      assert [] = FilterPersonResults.filter(person_results, %{dob: %{year: "2001", month: "02", day: "03"}})
    end
  end

  describe "filtering by a combination of filters" do
    setup do
      person_results = [
        %PersonResult{
          city: "Springfield",
          email_addresses: ["john@example.com"],
          first_name: "JOHN1",
          last_name: "Lastname",
          middle_name: nil,
          phone_numbers: [
            %PhoneNumber{
              phone: "415 555 1234",
              source: ["Work Affiliations"]
            },
            %PhoneNumber{
              phone: "",
              source: ["Work Affiliations"]
            }
          ],
          reported_date: nil,
          state: "CA",
          street: "123 MARKET ST FL 3",
          zip_code: "94103"
        },
        %PersonResult{
          city: "Springfield",
          email_addresses: ["john@example.com"],
          first_name: "JOHN2",
          last_name: "Lastname",
          middle_name: nil,
          phone_numbers: [
            %PhoneNumber{
              phone: "517 555 1234",
              source: ["Work Affiliations"]
            }
          ],
          reported_date: nil,
          state: "CA",
          street: "123 MARKET ST FL 3",
          zip_code: "94103"
        },
        %PersonResult{
          city: "Springfield",
          email_addresses: ["john@example.com"],
          first_name: "JOHN3",
          last_name: "Lastname",
          middle_name: nil,
          phone_numbers: [
            %PhoneNumber{
              phone: "555 555 1234",
              source: ["Work Affiliations"]
            }
          ],
          reported_date: nil,
          state: "NY",
          street: "123 MARKET ST FL 3",
          zip_code: "94103"
        }
      ]

      [person_results: person_results]
    end

    test "only returns records that match those filters", %{person_results: person_results} do
      assert [%{first_name: "JOHN1"}] = FilterPersonResults.filter(person_results, %{city: "Springfield", state: "CA", phone: "+1 415 555 1234"})
    end
  end

  defp make_person(attrs) do
    defaults = [dob: ~D[1980-01-01], first_name: "Firstname", phone: "(415) 555-1234"]
    attrs = Keyword.merge(defaults, attrs) |> Enum.into(%{})

    %PersonResult{
      city: "City",
      dob: attrs.dob,
      email_addresses: ["john@example.com"],
      first_name: attrs.first_name,
      last_name: "Lastname",
      middle_name: nil,
      phone_numbers: [
        %PhoneNumber{
          phone: attrs.phone,
          source: ["Work Affiliations"]
        },
        %PhoneNumber{
          phone: "",
          source: ["Work Affiliations"]
        }
      ],
      reported_date: nil,
      state: "NY",
      street: "123 MARKET ST FL 3",
      zip_code: "94103"
    }
  end
end
