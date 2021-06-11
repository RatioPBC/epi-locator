defmodule EpiLocatorWeb.Plugs.PutRequestIdOnSession do
  @moduledoc """
  Plug that puts the request_id on the session.

  This is done so that a liveview can read the request_id value regardless of
  whether it's disconnected, i.e., a regular stateless connection, or connected,
  i.e., a websocket connection.
  """

  import Plug.Conn

  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _default) do
    conn |> put_session(:request_id, Logger.metadata()[:request_id])
  end
end
