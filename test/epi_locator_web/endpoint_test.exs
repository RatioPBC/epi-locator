defmodule EpiLocatorWeb.EndpointTest do
  use EpiLocatorWeb.ConnCase

  test "adds secure headers to responses", %{conn: conn} do
    conn =
      conn
      |> bypass_through()
      |> get("/")

    [cache_control] = get_resp_header(conn, "cache-control")
    [csp] = get_resp_header(conn, "content-security-policy")
    [sts] = get_resp_header(conn, "strict-transport-security")

    assert cache_control == "private, no-store"
    assert csp =~ ~r"default-src 'self'; img-src 'self'.*"
    assert sts =~ "max-age="
  end

  test "adds secure headers to static asset responses", %{conn: conn} do
    conn =
      conn
      |> bypass_through()
      |> get(Routes.static_path(@endpoint, "/assets/app.js"))

    [sts] = get_resp_header(conn, "strict-transport-security")

    assert sts =~ "max-age="
  end

  test "doesn't add for private_web admin section", %{conn: conn} do
    conn =
      conn
      |> bypass_through()
      |> get("/private/dashboard")

    [sts] = get_resp_header(conn, "strict-transport-security")

    assert [] == get_resp_header(conn, "content-security-policy")
    assert sts =~ "max-age="
  end
end
