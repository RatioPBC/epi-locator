defmodule EpiLocator.Application do
  @moduledoc false
  use Application
  require Cachex.Spec
  alias EpiLocator.Monitoring.TelemetryToLoggerBridge
  alias EpiLocator.Monitoring.TelemetryToMetricsBridge
  alias EpiLocator.Monitoring.TelemetryToQueryLogBridge

  def start(_type, _args) do
    EpiLocator.ThomsonReuters.Config.init()

    children = [
      EpiLocator.Repo,
      EpiLocatorWeb.Telemetry,
      {Phoenix.PubSub, name: EpiLocator.PubSub},
      EpiLocatorWeb.Endpoint,
      Supervisor.child_spec({Cachex, name: :enrichment_results, expiration: Cachex.Spec.expiration(default: EpiLocator.Search.Cache.ttl())}, id: :enrichment_results_cache),
      Supervisor.child_spec({Cachex, name: :signatures, expiration: Cachex.Spec.expiration(default: EpiLocator.Signature.ttl(:millisecond))}, id: :signatures_cache)
    ]

    TelemetryToLoggerBridge.setup()
    TelemetryToQueryLogBridge.setup()
    # We need a way to globally stub the MetricsAPIBehaviourMock. For now, we just guard against it being executed in test here.
    if Application.get_env(:epi_locator, :environment_name) != :test do
      TelemetryToMetricsBridge.setup()
    end

    opts = [strategy: :one_for_one, name: EpiLocator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    EpiLocatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
