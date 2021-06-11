defmodule EpiLocator.Signature.CacheTest do
  use ExUnit.Case, async: false

  alias EpiLocator.Signature.Cache

  describe "items in signatures cache" do
    test "last no longer than the TTL" do
      key = "some-signature"
      value = "doesn't matter"

      {:ok, nil} = Cache.get(key)
      {:ok, true} = Cache.put(key, value)
      assert match?({:ok, true}, Cache.exists?(key))

      Process.sleep(EpiLocator.Signature.ttl(:millisecond) + 1)
      assert match?({:ok, false}, Cache.exists?(key))
    end
  end

  test "clear/0" do
    Cache.put("a", 1)
    Cache.put("b", 1)
    Cache.put("c", 1)
    assert match?({:ok, 3}, Cache.clear())
  end
end
