defmodule EpiLocatorWeb.SearchLive do
  @moduledoc """
  LiveView that sends searches to Thomson Reuters and displays the results
  """

  use EpiLocatorWeb, :live_view

  import EpiLocatorWeb.SearchView, only: [chosen_name: 2, parent_guardian_present?: 1]

  alias EpiLocator.Search.CachingLookupApi
  alias EpiLocator.Search.FilterPersonResults
  alias EpiLocator.SearchChooser

  @first_page_search_results 5
  @refine_results_flag_name :refine_results

  def refine_results_flag_name(), do: @refine_results_flag_name

  defp commcare_api_config do
    config = Application.get_env(:epi_locator, :commcare_api_config)
    struct(CommcareAPI.Config, config)
  end

  defp system, do: Application.get_env(:epi_locator, :system)
  defp time, do: Application.get_env(:epi_locator, :time)
  defp patient_case_provider, do: Application.get_env(:epi_locator, :patient_case_provider)

  def mount(%{"user-id" => user_id, "case-id" => case_id, "domain" => domain} = _params, %{"request_id" => request_id} = _session, socket) do
    socket =
      socket
      |> assign(:user_id, user_id)
      |> assign(:case_id, case_id)
      |> assign(:domain, domain)
      |> assign_nils()
      |> assign(:dob, nil)
      |> assign_searching()
      |> assign(:request_id, request_id)
      |> assign(:refine_results_enabled, FunWithFlags.enabled?(@refine_results_flag_name))
      |> assign(:chosen?, false)
      |> assign(:search_chooser, SearchChooser.changeset(%SearchChooser{}))

    socket =
      if connected?(socket) do
        case patient_case_provider().get_patient_case(socket.assigns, commcare_api_config()) do
          {:ok, person_case} ->
            socket =
              socket
              |> assign(:patient_case, person_case)
              |> assign(:case_type, person_case.case_type)
              |> assign(:first_name, person_case.first_name)
              |> assign(:last_name, person_case.last_name)
              |> assign(:phone, person_case.phone_home)
              |> assign(:street, person_case.street)
              |> assign(:city, person_case.city)
              |> assign(:state, person_case.state)
              |> assign(:zip_code, person_case.zip_code)
              |> assign(:dob, person_case.dob)
              |> assign(:parent_guardian, person_case.interviewee_parent_name)

            send(self(), :start_search)
            socket

          {:error, _} ->
            socket
            |> assign(:chosen?, true)
            |> assign_search_results(nil)
        end
      else
        socket
      end

    ok(socket)
  end

  # Can this clause be deleted?  Need to figure out why query params are nil.
  def mount(_params, _session, socket) do
    socket
    |> assign_nils()
    |> assign_search_results(nil)
    |> ok()
  end

  def render(%{live_action: :access_denied} = assigns) do
    Phoenix.View.render(EpiLocatorWeb.SearchView, "access_denied.html", assigns)
  end

  def render(assigns) do
    Phoenix.View.render(EpiLocatorWeb.SearchView, "search.html", assigns)
  end

  def handle_info(:start_search, %{assigns: assigns} = socket) do
    if !parent_guardian_present?(assigns.patient_case), do: send(self(), :search)

    noreply(socket)
  end

  def handle_info(:search, socket) do
    send(self(), :searching)
    send(self(), :lookup_person)
    send(self(), :done_searching)

    noreply(socket)
  end

  def handle_info(:lookup_person, socket) do
    time_before = system().monotonic_time(:millisecond)

    case lookup_person(socket) do
      {:ok, search_results} ->
        socket
        |> report_telemetry_metrics(:success, time_before, %{count: length(search_results)})
        |> assign_search_results(search_results)

      {:error, :no_results, _message} ->
        socket
        |> report_telemetry_metrics(:no_results, time_before)
        |> assign_search_results(:no_results)

      _error ->
        socket
        |> report_telemetry_metrics(:error, time_before)
        |> assign_search_results(nil)
    end
    |> noreply()
  end

  def handle_info(:searching, socket) do
    socket
    |> assign(:chosen?, true)
    |> assign(:searching?, true)
    |> noreply()
  end

  def handle_info(:done_searching, socket) do
    socket
    |> assign(:chosen?, true)
    |> assign(:searching?, false)
    |> noreply()
  end

  def handle_info({:refine_search_results, filters}, %{assigns: %{all_search_results: all_search_results}} = socket) do
    alias EpiLocator.{RefinementLog, Repo}
    refined_search_results = FilterPersonResults.filter(all_search_results, filters)

    %RefinementLog{}
    |> RefinementLog.changeset(
      Enum.reduce(
        filters,
        %{
          user: socket.assigns.user_id,
          timestamp: time().utc_now(),
          domain: socket.assigns.domain,
          case_type: socket.assigns.case_type,
          total_results: length(all_search_results),
          refined_results: length(refined_search_results)
        },
        fn {k, _}, acc -> Map.put(acc, k, true) end
      )
    )
    |> Repo.insert()

    assign(socket, :refined_search_results, refined_search_results) |> noreply()
  end

  def handle_info(:reset_refine_form, socket),
    do: assign(socket, :refined_search_results, :unrefined) |> noreply()

  def handle_event("choose", %{"search_chooser" => %{"source" => source}}, socket) do
    send(self(), :reset_refine_form)
    {first_name, last_name} = chosen_name(source, socket.assigns)
    changeset = SearchChooser.changeset(%SearchChooser{source: source})

    socket =
      socket
      |> assign(:chosen?, true)
      |> assign(:searching?, true)
      |> assign(:chosen_first_name, first_name)
      |> assign(:chosen_last_name, last_name)
      |> assign(:search_chooser, changeset)
      |> assign(:search_case_or_parent_guardian, source)

    send(self(), :search)

    noreply(socket)
  end

  def handle_event("show-all-results", _, %{assigns: %{all_search_results: all_search_results}} = socket) do
    socket =
      socket
      |> assign(:visible_search_results, all_search_results)
      |> assign(:show_all_results_button, false)

    socket |> noreply()
  end

  defp lookup_person(%{assigns: assigns}) do
    first_name = assigns.chosen_first_name || assigns.first_name
    last_name = assigns.chosen_last_name || assigns.last_name

    person_data = [
      first_name: first_name,
      last_name: last_name,
      street: assigns.street,
      city: assigns.city,
      state: assigns.state,
      phone: assigns.phone,
      zip_code: assigns.zip_code,
      dob: assigns.dob
    ]

    CachingLookupApi.lookup_person(assigns.case_id, person_data)
  end

  defp report_telemetry_metrics(%{assigns: assigns} = socket, name, time_before, additional_metrics \\ %{}) do
    metadata =
      %{
        domain: assigns.domain,
        case_id: assigns.case_id,
        case_type: assigns.case_type,
        module: __MODULE__,
        msec_elapsed: system().monotonic_time(:millisecond) - time_before,
        timestamp: time().utc_now(),
        user: assigns.user_id
      }
      |> Map.merge(additional_metrics)

    :telemetry.execute([:epi_locator, :tr, :search, name], %{}, metadata)

    socket
  end

  defp assign_nils(socket) do
    socket
    |> assign(:case_type, nil)
    |> assign(:chosen_first_name, nil)
    |> assign(:chosen_last_name, nil)
    |> assign(:first_name, nil)
    |> assign(:last_name, nil)
    |> assign(:patient_case, nil)
    |> assign(:phone, nil)
    |> assign(:street, nil)
    |> assign(:city, nil)
    |> assign(:state, nil)
    |> assign(:zip_code, nil)
    |> assign(:search_case_or_parent_guardian, nil)
  end

  defp assign_searching(socket) do
    socket
    |> assign(:all_search_results, nil)
    |> assign(:refined_search_results, :unrefined)
    |> assign(:hidden_result_count, 0)
    |> assign(:searching?, true)
    |> assign(:show_all_results_button, false)
    |> assign(:visible_search_results, nil)
  end

  defp assign_search_results(socket, results) when is_list(results) do
    hidden_result_count = length(results) - @first_page_search_results

    socket
    |> assign(:all_search_results, results)
    |> assign(:hidden_result_count, hidden_result_count)
    |> assign(:searching?, false)
    |> assign(:show_all_results_button, hidden_result_count > 0)
    |> assign(:visible_search_results, results |> Enum.take(@first_page_search_results))
  end

  defp assign_search_results(socket, results) do
    socket
    |> assign(:all_search_results, results)
    |> assign(:hidden_result_count, 0)
    |> assign(:searching?, false)
    |> assign(:show_all_results_button, false)
    |> assign(:visible_search_results, results)
  end

  def refine_search_results(params) do
    send(self(), {:refine_search_results, params})
  end

  def reset_refine_form(_params) do
    send(self(), :reset_refine_form)
  end
end
