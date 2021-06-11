defmodule EpiLocatorWeb.SignatureController do
  use EpiLocatorWeb, :controller

  def verify(conn, _params) do
    text(conn, "Signature verification")
  end
end
