defmodule EpiLocator.Monitoring.MetricsAPIBehaviour do
  @moduledoc """
  Provides a mockable interface around sending metrics
  """

  @callback send(any(), Keyword.t()) :: any()
end
