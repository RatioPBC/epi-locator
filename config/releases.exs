# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

config :epi_locator,
  commcare_signature_key: System.fetch_env!("COMMCARE_SIGNATURE_KEY"),
  commcare_signature_secret: System.fetch_env!("COMMCARE_SIGNATURE_SECRET"),
  environment_name: System.fetch_env!("RELEASE_LEVEL"),
  enrichment_cache_pepper: Euclid.Extra.Random.string()

config :epi_locator, EpiLocatorWeb.Endpoint,
  check_origin: false,
  http: [transport_options: [socket_opts: [:inet6]]],
  root: ".",
  server: true,
  url: [scheme: "https"]

config :epi_locator, EpiLocator.Repo,
  pool_size: "POOL_SIZE" |> System.get_env("15") |> String.to_integer(),
  show_sensitive_data_on_connection_error: false,
  ssl: System.get_env("DBSSL", "true") == "true",
  connection_info: System.fetch_env!("DATABASE_SECRET")

defmodule SentryConfig do
  def ca_bundle, do: System.get_env("SENTRY_CA_BUNDLE")
  def hackney_opts(bundle \\ ca_bundle())
  def hackney_opts(nil), do: []
  def hackney_opts(cert) when is_binary(cert), do: [ssl_options: [cacertfile: cert]]
end

# Configured in EpiLocator.Application.configure_sentry/0
config :sentry,
  ca_bundle: SentryConfig.ca_bundle(),
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: "RELEASE_LEVEL" |> System.fetch_env!() |> String.to_existing_atom(),
  included_environments: [:staging, :prod],
  hackney_opts: SentryConfig.hackney_opts()

config :epi_locator, :commcare_api_config,
  username: System.fetch_env!("COMMCARE_USERNAME"),
  user_id: System.fetch_env!("COMMCARE_USER_ID"),
  api_token: System.fetch_env!("COMMCARE_API_TOKEN")

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :epi_locator, EpiLocatorWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
