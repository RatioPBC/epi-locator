defmodule EpiLocatorWeb.AdminSearchView do
  use EpiLocatorWeb, :view
  import EpiLocatorWeb.SearchView, only: [number_of_search_results: 1]

  def phone_search_radio_button_checked("phone"), do: "checked"
  def phone_search_radio_button_checked(_), do: nil

  def person_search_radio_button_checked("person"), do: "checked"
  def person_search_radio_button_checked(_), do: nil

  def sources(sources), do: Enum.join(sources, ", ")

  def state_options do
    [
      {"-", nil},
      {"Alabama", "AL"},
      {"Alaska", "AK"},
      {"Arizona", "AZ"},
      {"Arkansas", "AR"},
      {"California", "CA"},
      {"Colorado", "CO"},
      {"Connecticut", "CT"},
      {"Delaware", "DE"},
      {"Florida", "FL"},
      {"Georgia", "GA"},
      {"Hawaii", "HI"},
      {"Idaho", "ID"},
      {"Illinois", "IL"},
      {"Indiana", "IN"},
      {"Iowa", "IA"},
      {"Kansas", "KS"},
      {"Kentucky", "KY"},
      {"Louisiana", "LA"},
      {"Maine", "ME"},
      {"Maryland", "MD"},
      {"Massachusetts", "MA"},
      {"Michigan", "MI"},
      {"Minnesota", "MN"},
      {"Mississippi", "MS"},
      {"Missouri", "MO"},
      {"Montana", "MT"},
      {"Nebraska", "NE"},
      {"Nevada", "NV"},
      {"New Hampshire", "NH"},
      {"New Jersey", "NJ"},
      {"New Mexico", "NM"},
      {"New York", "NY"},
      {"North Carolina", "NC"},
      {"North Dakota", "ND"},
      {"Ohio", "OH"},
      {"Oklahoma", "OK"},
      {"Oregon", "OR"},
      {"Pennsylvania", "PA"},
      {"Rhode Island", "RI"},
      {"South Carolina", "SC"},
      {"South Dakota", "SD"},
      {"Tennessee", "TN"},
      {"Texas", "TX"},
      {"Utah", "UT"},
      {"Vermont", "VT"},
      {"Virginia", "VA"},
      {"Washington", "WA"},
      {"West Virginia", "WV"},
      {"Wisconsin", "WI"},
      {"Wyoming", "WY"}
    ]
  end
end
