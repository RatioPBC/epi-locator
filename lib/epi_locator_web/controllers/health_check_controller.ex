defmodule EpiLocatorWeb.HealthCheckController do
  use EpiLocatorWeb, :controller

  def index(conn, _params) do
    text(conn, "OK")
  end
end
