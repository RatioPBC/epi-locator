defmodule EpiLocator.TRClientBehaviour do
  @moduledoc """
  Provides a mockable interface for querying Thomson Reuters
  """

  @callback person_search(Keyword.t()) :: {:ok, String.t()} | {:error, String.t()}
  @callback person_search_results(String.t()) :: {:ok, any()} | {:error, String.t()}
  @callback phone_search(Keyword.t()) :: {:ok, String.t()} | {:error, String.t()}
  @callback phone_search_results(String.t()) :: {:ok, any()} | {:error, String.t()}
end
