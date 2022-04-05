defmodule EpiLocator.TRClient do
  @moduledoc """
  Queries Thomson Reuters for people.
  """

  @behaviour EpiLocator.TRClientBehaviour
  require Logger

  alias EpiLocator.HTTPoisonSSL

  @flag_name :tr_client
  @person_search_api "api/v3/person/searchResults"

  defp http_client(), do: Application.get_env(:epi_locator, __MODULE__)[:http_client]

  def flag_name, do: @flag_name

  defp enabled?, do: FunWithFlags.enabled?(@flag_name)

  @impl EpiLocator.TRClientBehaviour
  def person_search(search_args) do
    do_person_search(enabled?(), search_args)
  end

  defp do_person_search(false, _search_args) do
    error = "TR disabled"
    Logger.error(error)
    {:error, error}
  end

  defp do_person_search(true, search_args) do
    person_search_url()
    |> http_client().post(person_search_body(search_args), headers(), http_options())
    |> parse_response()
    |> case do
      {:ok, xml_map} ->
        xml_map
        |> Map.get("PersonResults")
        |> Map.get("Uri")
        |> case do
          nil ->
            message = "no search results URL returned from Thomson Reuters"
            Logger.info(message)
            {:error, :no_results, message}

          url ->
            {:ok, url}
        end

      {:error, error} ->
        Logger.error(error)
        {:error, error}
    end
  end

  def person_search_url, do: url(@person_search_api)

  def url(api_path) do
    endpoint = config!(:endpoint)
    "https://#{endpoint}/#{api_path}"
  end

  @impl EpiLocator.TRClientBehaviour
  def person_search_results(uri), do: search_results(uri, "{http://clear.thomsonreuters.com/api/search/2.0}PersonResultsPageV3")

  defp search_results(uri, key) do
    uri
    |> http_client().get(headers(), http_options())
    |> parse_response()
    |> case do
      {:ok, xml_map} ->
        {:ok, xml_map |> Map.get(key)}

      {:error, error} ->
        Logger.error(error)
        {:error, error}
    end
  end

  defp headers do
    auth = config!(:basic_auth)
    ["content-type": "application/xml", Authorization: "Basic #{auth}"]
  end

  def person_search_body(first_name: first_name, last_name: last_name, street: street, city: city, state: state, phone: phone, zip_code: zip_code, dob: _dob) do
    assigns =
      search_assigns(%{
        first_name: first_name,
        last_name: last_name,
        street: street,
        city: city,
        state: state,
        phone: phone,
        zip_code: zip_code,
        dob: format_date(nil)
      })

    Phoenix.View.render(EpiLocatorWeb.TRView, "person_search.xml", assigns)
  end

  defp search_assigns(%{zip_code: "00000"} = assigns),
    do: %{assigns | zip_code: nil}

  defp search_assigns(assigns),
    do: assigns

  def format_date(nil), do: "**/**/****"

  def format_date(%Date{year: year, month: month, day: day}) do
    "~2..0B/~2..0B/~4..0B"
    |> :io_lib.format([month, day, year])
    |> to_string()
  end

  def format_date(date) when is_binary(date), do: date

  defp parse_response({:ok, %{status_code: 200, body: body}}), do: {:ok, XmlToMap.naive_map(body)}
  defp parse_response({:ok, %{status_code: status_code, body: body}}), do: {:error, "Status code #{status_code} returned from Thomson Reuters.  Body: #{body}"}

  def http_options, do: HTTPoisonSSL.poison_http_options(private_key(), public_cert(), cert_password())

  def cert_password, do: config!(:cert_password)

  # See the directions in the README about "TR Access" to get the private key and public cert:
  def private_key, do: :private_key |> config!() |> String.trim()
  def public_cert, do: :public_cert |> config!() |> String.trim()
  # ----------------------------------------------------------------------------------------

  defp config, do: Application.fetch_env!(:epi_locator, __MODULE__)
  defp config!(key), do: config() |> Keyword.fetch!(key)
end
