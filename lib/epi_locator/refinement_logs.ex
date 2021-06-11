defmodule EpiLocator.RefinementLog do
  use Timex
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "refinement_logs" do
    field(:city, :boolean, default: false)
    field(:dob, :boolean, default: false)
    field(:first_name, :boolean, default: false)
    field(:last_name, :boolean, default: false)
    field(:phone, :boolean, default: false)
    field(:refined_results, :integer)
    field(:state, :boolean, default: false)
    field(:total_results, :integer)
    field(:user, :string)
    field(:timestamp, :utc_datetime)
    field(:domain, :string)
    field(:case_type, :string)
  end

  @doc false
  def changeset(refinement_log, attrs) do
    refinement_log
    |> cast(attrs, ~w[first_name last_name city state phone dob user total_results refined_results timestamp domain case_type]a)
    |> validate_required(~w[user total_results refined_results timestamp domain case_type]a)
  end

  def headers, do: ~w[ case_type domain timestamp user total_results refined_results first_name last_name dob phone city state ]a

  def summary_headers, do: ~w[ week_of case_type domain total_refinements unique_users first_name last_name dob phone city state ]a

  def in_year_and_month(year, month) do
    start_date = Timex.parse!("#{year}-#{month}-01T00:00:00", "{ISO:Extended}")
    end_date = Timex.end_of_month(start_date)

    from(q in __MODULE__,
      where: ^start_date <= q.timestamp and q.timestamp <= ^end_date
    )
  end

  def summaries(year, month) do
    from(t in in_year_and_month(year, month),
      select: %{
        week: fragment("EXTRACT(WEEK FROM ?) as week", t.timestamp),
        domain: t.domain,
        case_type: t.case_type,
        total_refinements: count(),
        unique_users: fragment("COUNT(DISTINCT ?)", t.user),
        city: fragment("COUNT(*) FILTER (WHERE ? = true)", t.city),
        state: fragment("COUNT(*) FILTER (WHERE ? = true)", t.state),
        first_name: fragment("COUNT(*) FILTER (WHERE ? = true)", t.first_name),
        last_name: fragment("COUNT(*) FILTER (WHERE ? = true)", t.last_name),
        dob: fragment("COUNT(*) FILTER (WHERE ? = true)", t.dob),
        phone: fragment("COUNT(*) FILTER (WHERE ? = true)", t.phone)
      },
      order_by: [t.domain, fragment("week"), t.case_type],
      group_by: [t.domain, fragment("week"), t.case_type]
    )
    |> EpiLocator.Repo.stream()
    |> Stream.map(fn row ->
      row
      |> Map.put(:week_of, Timex.from_iso_triplet({String.to_integer(year), trunc(row.week), 1}) |> Timex.format!("{M}/{D}/{YYYY}"))
    end)
  end
end
