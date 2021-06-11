defmodule EpiLocator.Signature.Cache do
  @moduledoc """
  Provides helper functions for the signature cache.
  """

  @cache :signatures

  def clear(options \\ []), do: Cachex.clear(@cache, options)
  def exists?(key, options \\ []), do: Cachex.exists?(@cache, key, options)
  def get(key, options \\ []), do: Cachex.get(@cache, key, options)
  def put(key, value, options \\ []), do: Cachex.put(@cache, key, value, options)
end
