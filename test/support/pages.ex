defmodule EpiLocatorWeb.Test.Pages do
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias EpiLocatorWeb.Test
  alias Phoenix.LiveViewTest.View

  @endpoint EpiLocatorWeb.Endpoint

  def visit(conn, path, option \\ nil)

  def visit(%Plug.Conn{} = conn, path, nil) do
    {:ok, view, _html} = live(conn, path)
    view
  end

  def parse(%Plug.Conn{} = conn),
    do: conn |> html_response(200) |> Test.Html.parse_doc()

  def parse(%View{} = view),
    do: view |> render() |> Test.Html.parse()

  def parse(html_string) when is_binary(html_string),
    do: html_string |> Test.Html.parse_doc()
end
