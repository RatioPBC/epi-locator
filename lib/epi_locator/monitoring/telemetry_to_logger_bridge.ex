defmodule EpiLocator.Monitoring.TelemetryToLoggerBridge do
  require Logger

  @telemetry_metrics_handler_id "telemetry-to-logger-bridge"

  @admin_search_success [:epi_locator, :tr, :admin_search, :success]
  @search_success [:epi_locator, :tr, :search, :success]

  @metrics_names [
    @admin_search_success,
    @search_success
  ]

  def telemetry_handler_id, do: @telemetry_metrics_handler_id

  def setup do
    :telemetry.attach_many(
      telemetry_handler_id(),
      @metrics_names,
      &handle_event/4,
      nil
    )

    :ok
  end

  def handle_event(@admin_search_success, _measure, %{count: count, module: module}, _config) do
    Logger.info("[#{module}] #{count} search results returned from Thomson Reuters")
  end

  def handle_event(@search_success, _measure, %{case_id: case_id, count: count, domain: domain, module: module, user: user}, _config) do
    Logger.info("[#{module}] User[#{user}] Case[#{case_id}] Domain[#{domain}] received #{count} search results returned from Thomson Reuters")
  end
end
