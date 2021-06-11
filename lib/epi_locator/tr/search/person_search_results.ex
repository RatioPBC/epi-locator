defmodule EpiLocator.Search.PersonSearchResults do
  @moduledoc """
  Parses a document node with multiple search results into an enum of EpiLocator.Search.PersonResult
  """

  alias EpiLocator.Search.PersonResult

  def new(results) do
    result_group = results["ResultGroup"]
    search_results = if is_list(result_group), do: result_group, else: [result_group]
    search_results |> Enum.map(&PersonResult.new(&1))
  end
end
