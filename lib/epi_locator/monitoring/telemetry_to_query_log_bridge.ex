defmodule EpiLocator.Monitoring.TelemetryToQueryLogBridge do
  alias EpiLocator.QueryResultLog
  alias EpiLocator.Repo

  @telemetry_metrics_handler_id "telemetry-to-query-log-bridge"
  def telemetry_handler_id, do: @telemetry_metrics_handler_id

  @search_error [:epi_locator, :tr, :search, :error]
  @search_no_results [:epi_locator, :tr, :search, :no_results]
  @search_success [:epi_locator, :tr, :search, :success]

  @metrics_names [
    @search_error,
    @search_no_results,
    @search_success
  ]

  def setup do
    :telemetry.attach_many(
      telemetry_handler_id(),
      @metrics_names,
      &handle_event/4,
      nil
    )

    :ok
  end

  def handle_event(@search_error, _measure, metadata, _config),
    do: log_query(metadata |> Map.merge(%{success: false, count: 0}))

  def handle_event(@search_no_results, _measure, metadata, _config),
    do: log_query(metadata |> Map.merge(%{success: true, count: 0}))

  def handle_event(@search_success, _measure, metadata, _config),
    do: log_query(metadata |> Map.put(:success, true))

  # # #

  defp log_query(%{case_type: case_type, count: count, domain: domain, msec_elapsed: msec_elapsed, success: success, timestamp: timestamp, user: user}) do
    %QueryResultLog{}
    |> QueryResultLog.changeset(%{
      case_type: case_type,
      domain: domain,
      results: count,
      success: success,
      timestamp: timestamp,
      user: user,
      msec_elapsed: msec_elapsed
    })
    |> Repo.insert!()
  end
end
