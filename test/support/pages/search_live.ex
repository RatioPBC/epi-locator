defmodule EpiLocatorWeb.Test.Pages.SearchLive do
  import Phoenix.LiveViewTest

  alias EpiLocatorWeb.Test
  alias EpiLocatorWeb.Test.Pages
  alias Phoenix.LiveViewTest.View

  def visit(%Plug.Conn{} = conn, case_id, domain), do: Pages.visit(conn, "/search?user-id=qwe123&case-id=#{case_id}}&domain=#{domain}")

  def click_exit_refined_mode(%View{} = view) do
    view |> element("#exit-refined-mode") |> render_click()

    view
  end

  def refined_results_count(%View{} = view), do: view |> Pages.parse() |> Test.Html.text(role: "refined-results-count")
  def showing_no_matching_refined_results?(%View{} = view), do: view |> Pages.parse() |> Test.Html.present?(role: "no-refined-results")
  def showing_refined_results_count?(%View{} = view), do: view |> Test.Html.has_role?("refined-results-count")
  def visible_person_result_names(%View{} = view), do: view |> Pages.parse() |> Test.Html.all(".search-result .full-name", as: :text)
end
