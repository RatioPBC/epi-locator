defmodule EpiLocatorWeb.Test.Components.RefineSearchResults do
  import Phoenix.LiveViewTest

  alias EpiLocatorWeb.Test
  alias EpiLocatorWeb.Test.Html
  alias EpiLocatorWeb.Test.Pages
  alias Phoenix.LiveViewTest.View

  def change_form(%View{} = view, params) do
    view
    |> form("#refine-search-results-form", %{"filters_form" => params})
    |> render_change()

    view
  end

  def city(%View{} = view), do: input_value(view, "city")
  def click_reset_button(%View{} = view), do: view |> element("#reset-form") |> render_click()
  def first_name(%View{} = view), do: input_value(view, "first-name")
  def last_name(%View{} = view), do: input_value(view, "last-name")
  def phone(%View{} = view), do: input_value(view, "phone")

  def refine_results(%View{} = view, params) do
    view
    |> form("#refine-search-results-form", %{"filters_form" => params})
    |> render_submit()

    view
  end

  def state(%View{} = view),
    do: view |> Pages.parse() |> Test.Html.text("#refine-search-results-form select#state option[selected]")

  def dob(%View{} = view) do
    html = view |> Pages.parse()
    year = Test.Html.find!(html, "#refine-search-results-form select#year option[selected]") |> Test.Html.attr("value") |> List.first()
    month = Test.Html.find!(html, "#refine-search-results-form select#month option[selected]") |> Test.Html.attr("value") |> List.first()
    day = Test.Html.find!(html, "#refine-search-results-form select#day option[selected]") |> Test.Html.attr("value") |> List.first()

    {year, month, day}
  end

  def dob_components_are_blank?(%View{} = view) do
    ["", "", ""] == view |> Pages.parse() |> Test.Html.find("#refine-search-results-form [data-role=dob] option[selected]") |> Test.Html.attr("value")
  end

  def visible?(%View{} = view),
    do: view |> render() |> Html.parse() |> Html.has_role?("refine-results")

  # # #

  defp input_value(view, id), do: view |> Pages.parse() |> Test.Html.find!("#refine-search-results-form input##{id}") |> Test.Html.attr("value") |> List.first()
end
