defmodule EpiLocatorWeb.LiveComponents.RefineSearchResults do
  use EpiLocatorWeb, :live_component

  import EpiLocatorWeb.SearchView, only: [chosen_name: 2]

  defmodule FiltersForm do
    use Ecto.Schema

    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field(:first_name, :string, null: false, default: "")
      field(:last_name, :string, null: false, default: "")
      field(:city, :string, null: false, default: "")
      field(:state, :string, null: false, default: "")
      field(:phone, :string, null: false, default: "")
      field(:dob_year, :string, null: false, default: "")
      field(:dob_month, :string, null: false, default: "")
      field(:dob_day, :string, null: false, default: "")
    end

    @optional_attrs ~w{first_name city state phone dob_year dob_month dob_day}a

    def changeset(filters_form, params) do
      filters_form
      |> cast(params, @optional_attrs)
    end

    def filters_form(%{patient_case: patient_case, search_case_or_parent_guardian: search_case_or_parent_guardian}) do
      {dob_year, dob_month, dob_day} = dob_for(search_case_or_parent_guardian, patient_case)
      {first_name, last_name} = chosen_name(search_case_or_parent_guardian, patient_case)

      %FiltersForm{
        first_name: first_name |> normalize(),
        last_name: last_name |> normalize(),
        city: patient_case.city |> normalize(),
        state: patient_case.state |> normalize(),
        phone: patient_case.phone_home |> normalize(),
        dob_year: dob_year,
        dob_month: dob_month,
        dob_day: dob_day
      }
    end

    defp dob_for(nil, patient_case), do: dob_for("index_case", patient_case)
    defp dob_for("index_case", patient_case), do: dob_components(patient_case.dob)
    defp dob_for("parent_guardian", _patient_case), do: dob_components(nil)

    defp dob_components(%Date{} = dob) do
      {dob.year, dob.month |> pad(), dob.day |> pad()}
    end

    defp dob_components(_), do: {"", "", ""}
    defp pad(component), do: component |> Integer.to_string() |> String.pad_leading(2, "0")
    defp normalize(f), do: f || ""
  end

  def preload(list_of_assigns) do
    Enum.map(list_of_assigns, fn assigns ->
      filters_form = FiltersForm.filters_form(assigns)
      changeset = FiltersForm.changeset(filters_form, %{})

      assigns
      |> Map.put(:changeset, changeset)
      |> Map.put(:filters_form, filters_form)
    end)
  end

  def handle_event("refine", %{"filters_form" => params}, socket) do
    prepare_parameters_for_callback(params)
    |> socket.assigns.on_refine_search_results.()

    socket |> noreply()
  end

  def handle_event("change", %{"filters_form" => params}, socket) do
    update_form(socket, params)
  end

  def handle_event("reset", params, socket) do
    params
    |> prepare_parameters_for_callback()
    |> socket.assigns.on_reset_refine_form.()

    update_form(socket, %{})
  end

  def states() do
    ["" | ~w{AL AK AS AZ AR CA CO CT DE DC FL GA GO HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MP MT NE NV NH NJ NM NY NC ND OH OK OR PA PR RI SC SD TN TX UT VT VA VI WA WV WI WY}]
  end

  def years() do
    this_year = DateTime.utc_now().year
    ["" | (this_year - 100)..this_year |> Enum.reverse()]
  end

  def months() do
    [
      {"", ""},
      {"Jan", "01"},
      {"Feb", "02"},
      {"Mar", "03"},
      {"Apr", "04"},
      {"May", "05"},
      {"Jun", "06"},
      {"Jul", "07"},
      {"Aug", "08"},
      {"Sep", "09"},
      {"Oct", "10"},
      {"Nov", "11"},
      {"Dec", "12"}
    ]
  end

  def days() do
    ["" | 1..31 |> Enum.map(&String.pad_leading(Integer.to_string(&1), 2, "0"))]
  end

  # # #

  defp update_form(socket, params) do
    changeset = FiltersForm.changeset(socket.assigns.filters_form, params)

    socket
    |> assign(:changeset, changeset)
    |> noreply()
  end

  defp prepare_parameters_for_callback(params) do
    :maps.filter(fn _, v -> Euclid.Term.present?(v) end, params)
    |> prepare_dob_parameters()
    |> Euclid.Map.atomize_keys()
  end

  defp prepare_dob_parameters(params) do
    dob_params =
      %{}
      |> add_dob_component(:year, params["dob_year"])
      |> add_dob_component(:month, params["dob_month"])
      |> add_dob_component(:day, params["dob_day"])

    params
    |> Map.drop(~w{dob_year dob_month dob_day})
    |> add_dob(dob_params)
  end

  defp add_dob_component(dob_params, _name, component) when is_nil(component), do: dob_params
  defp add_dob_component(dob_params, name, component), do: Map.put(dob_params, name, component)
  defp add_dob(params, dob_params) when map_size(dob_params) > 0, do: Map.put(params, :dob, dob_params)
  defp add_dob(params, _dob_params), do: params
end
