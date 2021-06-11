defmodule EpiLocator.Search.PhoneSearchResults do
  @moduledoc """
    Parses a document node with multiple search results into an enum of EpiLocator.Search.PhoneResult
  """

  alias EpiLocator.Search.PhoneResult

  def new(results) do
    result_group = results["ResultGroup"]
    search_results = if is_list(result_group), do: result_group, else: [result_group]
    search_results |> Enum.map(&PhoneResult.new(&1)) |> Enum.reject(&(!&1.phone_number))
  end
end
