use Mix.Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
repo_opts =
  if socket_dir = System.get_env("PGDATA") do
    [socket_dir: socket_dir]
  else
    [username: "postgres", password: "postgres"]
  end

config :epi_locator,
       EpiLocator.Repo,
       [
         database: "epi_locator_test",
         pool: Ecto.Adapters.SQL.Sandbox,
         show_sensitive_data_on_connection_error: true
       ] ++ repo_opts

# capture all logs...
config :logger, level: :debug

# ... but show only warnings and up on the console
config :logger, :console, level: :warn

config :wallaby,
  driver: Wallaby.Chrome,
  chrome: [headless: true],
  hackney_options: [timeout: :infinity, recv_timeout: :infinity],
  screenshot_on_failure: true,
  js_errors: true

config :epi_locator, EpiLocatorWeb.Endpoint, server: true, port: 4001, url: [host: "example.com", port: 4001]
config :epi_locator, EpiLocator, signer: EpiLocator.SignatureMock
config :epi_locator, CommcareAPI.CommcareClient, http_client: EpiLocator.HTTPoisonMock
config :epi_locator, Oban, crontab: false, queues: false, plugins: false

config :epi_locator,
  enrichment_cache_pepper: "eFfdNHLZJTQSD+Igt4XcPMf/k4msmQs3",
  environment_name: :test,
  lookup_api: LookupApiBehaviourMock,
  metrics_api: MetricsAPIBehaviourMock,
  patient_case_provider: PatientCaseProviderMock,
  secure_session_cookies: false,
  sql_sandbox: true,
  system: EpiLocator.SystemMock,
  time: EpiLocator.TimeMock,
  tr_client: TRClientBehaviourMock

for {k, v} <- %{
      "RELEASE_LEVEL" => "test",
      "COMMCARE_USERNAME" => "ratio_user_1",
      "COMMCARE_USER_ID" => "abc123",
      "COMMCARE_API_TOKEN" => "johndoe@example.com:0000000060a6f9e4f46a069c2691083010cbb57d",
      "COMMCARE_SIGNATURE_KEY" => "faked-signature-key",
      "COMMCARE_SIGNATURE_SECRET" => "faked-signature-secret",
      "LIVE_VIEW_SIGNING_SALT" => "GdwB9kX0y82QGeQzNd2sIyV1clIY9qrWkTgGzv70ATjaYx9+wde2Q005So9Qu30y",
      "SECRET_KEY_BASE" => "PoZbi70MnJojDJ2W41mccqWsFaGa2Ea6uctuWxzaYd9I0XZceVT3lIGVLtzSCTw2",
      "PORT" => "4002"
    },
    do: System.put_env(k, v)
