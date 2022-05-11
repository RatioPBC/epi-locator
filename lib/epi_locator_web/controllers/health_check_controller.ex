defmodule EpiLocatorWeb.HealthCheckController do
  use EpiLocatorWeb, :controller

  alias CommcareAPI.CommcareClient
  alias CommcareAPI.Config

  def index(conn, _params) do
    text(conn, "OK")
  end

  def commcare(conn, _params) do
    case CommcareClient.ping(commcare_api_config()) do
      :ok ->
        text(conn, "OK")

      _ ->
        conn
        |> put_status(500)
        |> text("Cannot ping CommCare")
    end
  end

  defp commcare_api_config do
    config = Application.get_env(:epi_locator, :commcare_api_config)
    struct(Config, config)
  end
end
