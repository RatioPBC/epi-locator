defmodule EpiLocator.Monitoring.Cloudwatch do
  @moduledoc """
  Sends metric data to AWS Cloudwatch
  """

  @behaviour EpiLocator.Monitoring.MetricsAPIBehaviour
  @flag_name :cloudwatch_metrics

  def flag_name, do: @flag_name

  @impl EpiLocator.Monitoring.MetricsAPIBehaviour
  def send(metrics, opts) when is_map(metrics) do
    metrics
    |> to_metric_data(opts)
    |> send_metrics()
  end

  def to_metric_data(metrics, type: type) when is_map(metrics) do
    to_metric_data(metrics, type: type, dimensions: [])
  end

  def to_metric_data(metrics, type: type, dimensions: dimensions) when is_map(metrics) do
    environment = Application.get_env(:epi_locator, :environment_name)

    metrics
    |> Enum.map(fn {key, value} ->
      [metric_name: key, value: value, dimensions: dimensions ++ [{"Environment", environment}, {"Type", type}]]
    end)
  end

  defp send_metrics(metrics) do
    if FunWithFlags.enabled?(@flag_name) do
      metrics
      |> ExAws.Cloudwatch.put_metric_data("EpiLocator")
      |> ExAws.request()
    else
      metrics
    end
  end
end
