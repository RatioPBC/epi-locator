# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :epi_locator,
  commcare_signature_key: System.get_env("COMMCARE_SIGNATURE_KEY"),
  commcare_signature_secret: System.get_env("COMMCARE_SIGNATURE_SECRET"),
  enrichment_cache_pepper: System.get_env("ENRICHMENT_CACHE_PEPPER"),
  ecto_repos: [EpiLocator.Repo],
  secure_session_cookies: true

config :epi_locator, Oban,
  repo: EpiLocator.Repo,
  queues: [default: 10],
  plugins: [
    Oban.Pro.Plugins.Lifeline,
    Oban.Web.Plugins.Stats
  ]

config :epi_locator,
       EpiLocator.Repo,
       url: System.get_env("DATABASE_URL")

# Configures the endpoint
config :epi_locator, EpiLocatorWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: EpiLocatorWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: EpiLocator.PubSub,
  live_view: [signing_salt: "gkSfxdfC"],
  content_security_policy: "default-src 'self'; img-src 'self' https://*.s3.amazonaws.com",
  strict_transport_security: "max-age=31536000"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :esbuild,
  version: "0.14.0",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :dart_sass,
  version: "1.43.4",
  default: [
    args: ~w(css/app.scss ../priv/static/assets/app.css),
    cd: Path.expand("../assets", __DIR__)
  ]

config :epi_locator, EpiLocator, signer: EpiLocator.Signature, ttl: 10_000
config :epi_locator, CommcareAPI.CommcareClient, http_client: HTTPoison

config :epi_locator,
       EpiLocator.TRClient,
       []

config :fun_with_flags, :persistence,
  adapter: FunWithFlags.Store.Persistent.Ecto,
  repo: EpiLocator.Repo

config :fun_with_flags, :cache_bust_notifications,
  enabled: true,
  adapter: FunWithFlags.Notifications.PhoenixPubSub,
  client: EpiLocator.PubSub

config :epi_locator,
  lookup_api: EpiLocator.TrApi,
  metrics_api: EpiLocator.Monitoring.Cloudwatch,
  patient_case_provider: CommcareAPI,
  system: EpiLocator.System.Real,
  time: EpiLocator.Time.Real,
  tr_client: EpiLocator.TRClient

config :epi_locator, :commcare_api_config,
  username: System.get_env("COMMCARE_USERNAME"),
  user_id: System.get_env("COMMCARE_USER_ID"),
  api_token: System.get_env("COMMCARE_API_TOKEN")

config :sentry,
  ca_bundle: System.get_env("SENTRY_CA_BUNDLE"),
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: :dev

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
