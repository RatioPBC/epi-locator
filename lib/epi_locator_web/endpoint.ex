defmodule EpiLocatorWeb.Endpoint do
  use Sentry.PlugCapture
  use Phoenix.Endpoint, otp_app: :epi_locator
  @secure_session_cookies Application.compile_env!(:epi_locator, :secure_session_cookies)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_epi_locator_key",
    secure: @secure_session_cookies,
    signing_salt: "zdpxeIXe",
    same_site: "Lax",
    #
    # GW: This should ideally be set as an environment variable.
    # HOWEVER, it's not immediately clear to me when the socket() and plug() macros below are evaluated (are they
    # evaluated at compile time? can you give it as a run-time option somehow?)
    # So we'll hard-wire this value for now, and perhaps move it to an env variable later:
    encryption_salt: "pma6fx98f9pfuSuMTPLKv44OJDq+XNA8Q2HzmHw1SPNRv6lVw4n2Dps8c9FZYzVY"
  ]

  socket("/socket", EpiLocatorWeb.UserSocket,
    websocket: [timeout: 45_000],
    longpoll: false
  )

  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  plug(:ensure_browser_headers)

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :epi_locator,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :epi_locator)
  end

  plug(Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)

  plug(EpiLocatorWeb.Router)

  if Application.get_env(:epi_locator, :sql_sandbox) do
    plug(Phoenix.Ecto.SQL.Sandbox)
  end

  def init(:supervisor, opts), do: {:ok, load_system_env(opts)}

  defp ensure_browser_headers(%Plug.Conn{path_info: ["private" | _]} = conn, _opts) do
    put_resp_header(conn, "strict-transport-security", endpoint_config_for(:strict_transport_security))
  end

  defp ensure_browser_headers(conn, _opts) do
    conn
    |> put_resp_header("cache-control", "private, no-store")
    |> put_resp_header("content-security-policy", endpoint_config_for(:content_security_policy))
    |> put_resp_header("strict-transport-security", endpoint_config_for(:strict_transport_security))
  end

  defp load_system_env(opts) do
    Keyword.merge(opts,
      http: [port: System.get_env("PORT", "4000")],
      live_view: [signing_salt: System.fetch_env!("LIVE_VIEW_SIGNING_SALT")],
      secret_key_base: System.get_env("SECRET_KEY_BASE", ""),
      url: [host: System.get_env("CANONICAL_HOST", "localhost")]
    )
  end

  defp endpoint_config_for(key) do
    :epi_locator
    |> Application.get_env(EpiLocatorWeb.Endpoint, Keyword.new())
    |> Keyword.get(key)
  end
end
