defmodule EpiLocator.Monitoring.TelemetryToMetricsBridge do
  @telemetry_metrics_handler_id "telemetry-to-metrics-bridge"
  def telemetry_handler_id, do: @telemetry_metrics_handler_id

  @admin_search_error [:epi_locator, :tr, :admin_search, :error]
  @admin_search_success [:epi_locator, :tr, :admin_search, :success]
  @search_error [:epi_locator, :tr, :search, :error]
  @search_no_results [:epi_locator, :tr, :search, :no_results]
  @search_success [:epi_locator, :tr, :search, :success]

  @metrics_names [
    @admin_search_error,
    @admin_search_success,
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

  def handle_event(@admin_search_error, _measure, _meta, _config),
    do: %{"tr.admin_search.error.count" => 1} |> send_metrics_without_dimensions()

  def handle_event(@admin_search_success, _measure, %{count: count}, _config),
    do: %{"tr.admin_search.success.count" => 1, "tr.admin_search.results.count" => count} |> send_metrics_without_dimensions()

  def handle_event(@search_error, _measure, %{case_type: case_type, domain: domain}, _config),
    do: %{"tr.search.error.count" => 1} |> send_search_metrics(case_type, domain)

  def handle_event(@search_no_results, _measure, %{case_type: case_type, domain: domain}, _config),
    do: %{"tr.search.no_results.count" => 1} |> send_search_metrics(case_type, domain)

  def handle_event(@search_success, _measure, %{case_type: case_type, count: count, domain: domain}, _config),
    do: %{"tr.search.success.count" => 1, "tr.search.results.count" => count} |> send_search_metrics(case_type, domain)

  # # #

  defp metrics_api, do: Application.get_env(:epi_locator, :metrics_api)

  defp send_metrics_without_dimensions(metrics), do: metrics_api().send(metrics, type: "TR Search")

  defp send_search_metrics(metrics, case_type, domain) do
    metrics_api().send(metrics, type: "TR Search", dimensions: [{"Domain", domain}])
    metrics_api().send(metrics, type: "TR Search", dimensions: [{"CaseType", case_type}])
    send_metrics_without_dimensions(metrics)
  end
end
