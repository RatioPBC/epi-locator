defmodule EpiLocator.TrApi do
  alias EpiLocator.LookupApiBehaviour
  alias EpiLocator.Search.PersonSearchResults

  @behaviour LookupApiBehaviour

  defp tr_client, do: Application.get_env(:epi_locator, :tr_client)

  @impl LookupApiBehaviour
  def lookup_person(person_data) do
    with {:ok, url} <- tr_client().person_search(person_data),
         {:ok, results} <- tr_client().person_search_results(url) do
      search_results =
        results
        |> PersonSearchResults.new()

      {:ok, search_results}
    else
      error -> error
    end
  end
end
