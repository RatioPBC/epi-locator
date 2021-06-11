defmodule EpiLocatorWeb.SearchView do
  use EpiLocatorWeb, :view

  alias EpiLocatorWeb.LiveComponents.RefineSearchResults
  alias EpiLocatorWeb.SearchLive

  @no_dob "Unavailable"
  def format_date(nil), do: @no_dob
  def format_date(""), do: @no_dob

  def format_date(%Date{year: year, month: month, day: day}) do
    "~2..0B/~2..0B/~4..0B"
    |> :io_lib.format([month, day, year])
    |> to_string()
  end

  def full_name(%{first_name: first_name, middle_name: middle_name, last_name: last_name}) do
    [first_name, middle_name, last_name]
    |> Enum.reject(&(!&1))
    |> Enum.join(" ")
  end

  def number_of_search_results(nil), do: "0 results"
  def number_of_search_results([_one_result]), do: "1 result"
  def number_of_search_results(search_results) when length(search_results) > 5, do: "5+ results"
  def number_of_search_results(search_results), do: "#{length(search_results)} results"

  def raw_phone_number(nil), do: nil

  def raw_phone_number(phone_number) do
    phone_number
    |> String.replace("(", "")
    |> String.replace(")", "")
    |> String.replace("-", "")
    |> String.replace(" ", "")
  end

  def search_criteria(first_name, last_name, street, city, state, zip_code, phone) do
    full_name = [first_name, last_name] |> Enum.join(" ")

    [full_name, street, city, state, zip_code, phone]
    |> Enum.reject(&(!&1))
    |> Enum.map(&"\"#{&1}\"")
    |> Enum.join(", ")
  end

  def show_if_present(nil), do: nil

  def show_if_present(something) do
    content_tag(:h4, something)
  end

  def show_refine_search_results?(_refine_results_enabled = true, _all_search_results = nil), do: false
  def show_refine_search_results?(_refine_results_enabled = true, _all_search_results = :no_results), do: false
  def show_refine_search_results?(_refine_results_enabled = true, all_search_results) when length(all_search_results) > 1, do: true
  def show_refine_search_results?(_refine_results_enabled, _all_search_results), do: false

  def parent_guardian_present?(nil), do: false
  def parent_guardian_present?(%CommcareAPI.PatientCase{interviewee_parent_name: nil}), do: false
  def parent_guardian_present?(%CommcareAPI.PatientCase{interviewee_parent_name: ""}), do: false
  def parent_guardian_present?(%CommcareAPI.PatientCase{interviewee_parent_name: _}), do: true

  @type search_type :: String.t() | nil
  @spec chosen_name(search_type(), map()) :: {String.t(), String.t()}
  def chosen_name(nil, assigns), do: chosen_name("index_case", assigns)
  def chosen_name("index_case", assigns), do: {assigns.first_name, assigns.last_name}

  def chosen_name("parent_guardian", %{interviewee_parent_name: parent_guardian}) do
    chosen_name("parent_guardian", %{parent_guardian: parent_guardian})
  end

  def chosen_name("parent_guardian", %{parent_guardian: parent_guardian}) do
    [first_name | rest] = String.split(parent_guardian)
    last_name = Enum.join(rest, " ")
    {first_name, last_name}
  end
end
