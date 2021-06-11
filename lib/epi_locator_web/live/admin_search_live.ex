defmodule EpiLocatorWeb.AdminSearchLive do
  @moduledoc """
  Live view allowing admins to make searches against TR without being sent from commcare
  """

  use EpiLocatorWeb, :live_view
  require Logger

  alias EpiLocator.Search.PersonSearchResults
  alias EpiLocator.Search.PhoneSearchResults

  @default_search_type "person"

  def mount(_params, _session, socket) do
    socket
    |> assign(:search_type, @default_search_type)
    |> clear_form()
    |> put_flash(:error, """
      Note that TR records all searches. If you search for a celebrity's name, it will get flagged to the state.
      Please only search for data for which you have permission.
    """)
    |> ok()
  end

  def render(assigns), do: Phoenix.View.render(EpiLocatorWeb.AdminSearchView, "search.html", assigns)

  def handle_event(
        "search",
        %{
          "first-name" => first_name,
          "last-name" => last_name,
          "street" => street,
          "city" => city,
          "state" => state,
          "phone" => phone,
          "zip-code" => zip_code,
          "search-type" => search_type,
          "dob" => dob
        },
        socket
      ) do
    socket =
      socket
      |> assign(:first_name, first_name)
      |> assign(:last_name, last_name)
      |> assign(:street, street)
      |> assign(:city, city)
      |> assign(:state, state)
      |> assign(:phone, phone)
      |> assign(:zip_code, zip_code)
      |> assign(:dob, dob)
      |> assign(:search_type, search_type)
      |> assign(:search?, :in_progress)

    send(self(), {:search, search_type})
    socket |> noreply()
  end

  def handle_event("clear-form", %{}, socket) do
    socket |> clear_form() |> noreply()
  end

  def handle_info(
        {:search, "phone"},
        %{
          assigns: %{
            first_name: first_name,
            last_name: last_name,
            street: street,
            city: city,
            state: state,
            phone: phone,
            zip_code: zip_code
          }
        } = socket
      ) do
    with {:ok, url} <- tr_client().phone_search(first_name: first_name, last_name: last_name, street: street, city: city, state: state, phone: phone, zip_code: zip_code),
         {:ok, results} <- tr_client().phone_search_results(url) do
      search_results = results |> PhoneSearchResults.new()

      report_telemetry_metrics(:success, :phone, %{count: length(search_results)})

      socket
      |> assign(:visible_search_results, search_results)
      |> assign(:search?, :completed)
      |> clear_flash(:error)
    else
      _error ->
        report_telemetry_metrics(:error, :phone)

        socket
        |> assign(:visible_search_results, nil)
        |> assign(:search?, :completed)
    end
    |> noreply()
  end

  def handle_info(
        {:search, "person"},
        %{
          assigns: %{
            first_name: first_name,
            last_name: last_name,
            street: street,
            city: city,
            state: state,
            phone: phone,
            zip_code: zip_code,
            dob: dob
          }
        } = socket
      ) do
    with {:ok, url} <- tr_client().person_search(first_name: first_name, last_name: last_name, street: street, city: city, state: state, phone: phone, zip_code: zip_code, dob: dob),
         {:ok, results} <- tr_client().person_search_results(url) do
      search_results = results |> PersonSearchResults.new()
      report_telemetry_metrics(:success, :person, %{count: length(search_results)})

      socket
      |> assign(:visible_search_results, search_results)
      |> assign(:search?, :completed)
      |> clear_flash(:error)
    else
      _error ->
        report_telemetry_metrics(:error, :phone)

        socket
        |> assign(:visible_search_results, nil)
        |> assign(:search?, :completed)
    end
    |> noreply()
  end

  defp clear_form(socket) do
    socket
    |> assign(:visible_search_results, nil)
    |> assign(:first_name, nil)
    |> assign(:last_name, nil)
    |> assign(:street, nil)
    |> assign(:city, nil)
    |> assign(:state, nil)
    |> assign(:zip_code, nil)
    |> assign(:phone, nil)
    |> assign(:dob, nil)
    |> assign(:search?, :not_yet_initiated)
  end

  defp tr_client, do: Application.get_env(:epi_locator, :tr_client)

  defp report_telemetry_metrics(result, search_type, additional_metrics \\ %{}) do
    metadata =
      %{
        module: __MODULE__,
        search_type: search_type |> Atom.to_string()
      }
      |> Map.merge(additional_metrics)

    :telemetry.execute([:epi_locator, :tr, :admin_search, result], %{}, metadata)
  end
end
