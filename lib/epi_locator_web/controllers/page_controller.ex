defmodule EpiLocatorWeb.PageController do
  use EpiLocatorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def commcare_signature(conn, _params) do
    render(conn, "commcare_signature.html",
      case_id: config(:commcare_signature_test_case_id),
      domain: config(:commcare_signature_test_domain),
      nonce: EpiLocator.Signature.nonce(),
      user_id: config(:commcare_signature_test_user_id)
    )
  end

  defp config(key), do: Application.get_env(:epi_locator, key)
end
