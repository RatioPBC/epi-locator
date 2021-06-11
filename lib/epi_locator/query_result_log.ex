defmodule EpiLocator.QueryResultLog do
  use Timex
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "query_result_logs" do
    field(:case_type, :string)
    field(:domain, :string)
    field(:results, :integer)
    field(:success, :boolean, default: false)
    field(:timestamp, :utc_datetime)
    field(:user, :string)
    field(:msec_elapsed, :integer)
  end

  @doc false
  def changeset(query_result_log, attrs) do
    query_result_log
    |> cast(attrs, [:domain, :case_type, :success, :results, :timestamp, :msec_elapsed, :user])
    |> validate_required([:domain, :case_type, :success, :results, :timestamp])
  end

  def headers, do: ~w[ case_type domain results success timestamp msec_elapsed user ]a

  def in_year_and_month(year, month) do
    start_date = Timex.parse!("#{year}-#{month}-01T00:00:00", "{ISO:Extended}")
    end_date = Timex.end_of_month(start_date)

    from(q in __MODULE__,
      where: ^start_date <= q.timestamp and q.timestamp <= ^end_date
    )
  end

  def summaries_headers, do: ~w[ week_of domain case_type
                                 total_queries
                                 zero_result_successful_queries nonzero_result_successful_queries failed_queries
                                 mean_results_per_query median_results_per_query
                                 mean_msec median_msec
                                 unique_users
                               ]a

  def summaries(year, month) do
    from(t in in_year_and_month(year, month),
      select: %{
        week: fragment("EXTRACT(WEEK FROM ?) as week", t.timestamp),
        domain: t.domain,
        case_type: t.case_type,
        total_queries: count(),
        zero_result_successful_queries: fragment("COUNT(*) FILTER (WHERE ? = true AND ? = 0)", t.success, t.results),
        nonzero_result_successful_queries: fragment("COUNT(*) FILTER (WHERE ? = true AND ? > 0)", t.success, t.results),
        failed_queries: fragment("COUNT(*) FILTER (WHERE ? = false)", t.success),
        mean_results_per_query: fragment("AVG(?) FILTER (WHERE ? = true)", t.results, t.success),
        median_results_per_query: fragment("PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ?) FILTER (WHERE ? = true)", t.results, t.success),
        mean_msec: fragment("AVG(?) FILTER (WHERE ? = true)", t.msec_elapsed, t.success),
        median_msec: fragment("PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ?) FILTER (WHERE ? = true)", t.msec_elapsed, t.success),
        unique_users: fragment("COUNT(DISTINCT ?)", t.user)
      },
      order_by: [t.domain, fragment("week"), t.case_type],
      group_by: [t.domain, fragment("week"), t.case_type]
    )
    |> EpiLocator.Repo.stream()
    |> Stream.map(fn row ->
      row
      |> Map.put(:week_of, Timex.from_iso_triplet({String.to_integer(year), trunc(row.week), 1}) |> Timex.format!("{M}/{D}/{YYYY}"))
      |> Map.put(
        :mean_results_per_query,
        case row.mean_results_per_query do
          nil -> nil
          mean -> Decimal.round(mean, 2)
        end
      )
    end)
  end
end
