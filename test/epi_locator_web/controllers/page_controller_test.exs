defmodule EpiLocatorWeb.PageControllerTest do
  use EpiLocatorWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Covid-19 Response"
  end
end
