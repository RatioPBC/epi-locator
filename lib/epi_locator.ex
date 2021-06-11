defmodule EpiLocator do
  @moduledoc """
  EpiLocator provides the application logic to support contact enrichment for commcare contact tracing
  """

  def signer do
    Application.get_env(:epi_locator, __MODULE__)[:signer]
  end
end
