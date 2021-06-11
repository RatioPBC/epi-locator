defmodule EpiLocator.Search.CachingLookupApi do
  alias EpiLocator.Search.Cache

  defp lookup_api, do: Application.get_env(:epi_locator, :lookup_api)

  def lookup_person(case_id, person_data, pepper \\ get_pepper()) do
    with {:ok, key} <- cache_key(case_id, person_data, pepper),
         :ok <- exists?(key) do
      Cache.get(key)
    else
      {:missing, key} -> lookup_and_cache(key, person_data)
    end
  end

  defp lookup_and_cache(key, person_data) do
    case lookup_api().lookup_person(person_data) do
      {:ok, results} ->
        Cache.put(key, results)
        {:ok, results}

      response ->
        response
    end
  end

  def exists?(key) do
    case Cache.exists?(key) do
      {:ok, true} -> :ok
      {:ok, false} -> {:missing, key}
    end
  end

  def cache_key(case_id, person_data, pepper) do
    key =
      case_id
      |> concatenate(person_data)
      |> pepper(pepper)
      |> hash()

    {:ok, key}
  end

  defp concatenate(case_id, person_data) do
    Enum.reduce(person_data, case_id, fn
      {_key, nil}, acc -> acc
      {_key, val}, acc -> acc <> to_string(val)
    end)
  end

  defp pepper(string, pepper), do: pepper <> string
  defp hash(string), do: :crypto.hash(:sha512, string)

  defp get_pepper(), do: Application.get_env(:epi_locator, :enrichment_cache_pepper)
end
