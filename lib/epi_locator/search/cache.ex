defmodule EpiLocator.Search.Cache do
  @moduledoc """
  Provides helper functions for the enrichment_results cache.
  """

  @cache :enrichment_results

  def ttl(), do: 24 * 60 * 60 * 1000

  def clear(options \\ []), do: Cachex.clear(@cache, options)
  def exists?(key, options \\ []), do: Cachex.exists?(@cache, key, options)
  def get(key, options \\ []), do: Cachex.get(@cache, key, options)
  def put(key, value, options \\ []), do: Cachex.put(@cache, key, value, options)
end
