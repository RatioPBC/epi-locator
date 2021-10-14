defmodule EpiLocatorWeb.SearchViewTest do
  use EpiLocatorWeb.ConnCase, async: true
  use ExUnitProperties

  alias EpiLocatorWeb.SearchView

  describe "number_of_search_results" do
    test "returns '0 results' if no results" do
      assert SearchView.number_of_search_results(nil) == "0 results"
    end

    test "returns '1 result' if one result" do
      assert SearchView.number_of_search_results(["foo"]) == "1 result"
    end

    test "returns '5 results' if five results" do
      assert SearchView.number_of_search_results(["foo", "bar", "baz", "bat", "wat"]) == "5 results"
    end

    test "returns '5+ results' if > five results" do
      assert SearchView.number_of_search_results(["foo", "bar", "baz", "bat", "wat", "meow"]) == "5+ results"
    end
  end

  describe "search_criteria" do
    test "returns the search criteria surrounded by parens and separated by commas" do
      search_criteria = SearchView.search_criteria("John", "Doe", "123 Main St", "Anytown", "TX", "77623", "(123) 345-6789")
      assert search_criteria == ~s{"John Doe", "123 Main St", "Anytown", "TX", "77623", "(123) 345-6789"}
    end

    test "eliminates nil values" do
      search_criteria = SearchView.search_criteria("John", "Doe", nil, "Anytown", "TX", "77623", nil)
      assert search_criteria == ~s{"John Doe", "Anytown", "TX", "77623"}
    end
  end

  describe "full_name" do
    test "returns the name of the person" do
      person_results = %{first_name: "John", middle_name: nil, last_name: "Doe"}
      assert SearchView.full_name(person_results) == "John Doe"
    end

    test "returns the name of the person, including the middle name" do
      person_results = %{first_name: "John", middle_name: "C", last_name: "Doe"}
      assert SearchView.full_name(person_results) == "John C Doe"
    end
  end

  describe "show_if_present" do
    test "shows nothing if no content" do
      assert SearchView.show_if_present(nil) == nil
    end

    test "shows the text wrapped in an h4 if there is content" do
      assert SearchView.show_if_present("something") |> Phoenix.HTML.safe_to_string() == "<h4>something</h4>"
    end
  end

  describe "raw_phone_number" do
    test "removes parens and spaces" do
      assert SearchView.raw_phone_number("(123) 456-7890") == "1234567890"
    end

    test "doesn't blow up on nils" do
      assert SearchView.raw_phone_number(nil) == nil
    end
  end

  describe "format_date/1" do
    test "handles nil" do
      assert SearchView.format_date(nil) == "Unavailable"
      assert SearchView.format_date("") == "Unavailable"
    end

    test "formats the date to a nice looking string" do
      assert SearchView.format_date(~D[2020-02-28]) == "02/28/2020"
    end
  end

  describe "parent_guardian_present?/1" do
    test "returns true if interviewee_parent_name is set" do
      patient_case = %CommcareAPI.PatientCase{first_name: "John", last_name: "Doe", interviewee_parent_name: "something"}
      assert SearchView.parent_guardian_present?(patient_case)
    end

    test "returns false if patient_case is nil" do
      # if it's not loaded yet
      refute SearchView.parent_guardian_present?(nil)
    end

    test "returns false if interviewee_parent_name is nil" do
      patient_case = %CommcareAPI.PatientCase{first_name: "John", last_name: "Doe"}
      refute SearchView.parent_guardian_present?(patient_case)
    end

    test "returns false if interviewee_parent_name is empty" do
      patient_case = %CommcareAPI.PatientCase{first_name: "John", last_name: "Doe", interviewee_parent_name: ""}
      refute SearchView.parent_guardian_present?(patient_case)
    end
  end

  test "chosen_name/2" do
    check all(
            first_name <- string(:printable, min_length: 2),
            last_name <- string(:printable, min_length: 2)
          ) do
      name = "#{first_name} #{last_name}"
      [first_name | last_names] = String.split(name)
      last_name = last_names |> Enum.join(" ") |> String.trim()

      assert {^first_name, ^last_name} = SearchView.chosen_name("index_case", %{first_name: first_name, last_name: last_name})
      assert {^first_name, ^last_name} = SearchView.chosen_name(nil, %{first_name: first_name, last_name: last_name})
      assert {^first_name, ^last_name} = SearchView.chosen_name("parent_guardian", %{parent_guardian: name})
      assert {^first_name, ^last_name} = SearchView.chosen_name("parent_guardian", %{interviewee_parent_name: name})
    end
  end
end
