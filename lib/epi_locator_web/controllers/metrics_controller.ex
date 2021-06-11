defmodule EpiLocatorWeb.MetricsController do
  use EpiLocatorWeb, :controller
  alias EpiLocator.{Repo, QueryResultLog, RefinementLog}
  use Timex

  def index(conn, _) do
    render(conn, "index.html")
  end

  def all(conn, %{"year" => year, "month" => month}) do
    data = QueryResultLog.in_year_and_month(year, month) |> Repo.stream() |> Stream.map(&Map.from_struct/1)
    send_csv(conn, data, headers: QueryResultLog.headers(), filename: "#{year}-#{month}-all")
  end

  def summaries(conn, %{"year" => year, "month" => month}) do
    data = QueryResultLog.summaries(year, month)
    send_csv(conn, data, headers: QueryResultLog.summaries_headers(), filename: "#{year}-#{month}-summaries")
  end

  def refinement_summaries(conn, %{"year" => year, "month" => month}) do
    data = RefinementLog.summaries(year, month)
    send_csv(conn, data, headers: RefinementLog.summary_headers(), filename: "#{year}-#{month}-refinement-summaries")
  end

  def refinement_all(conn, %{"year" => year, "month" => month}) do
    data = RefinementLog.in_year_and_month(year, month) |> Repo.stream() |> Stream.map(&Map.from_struct/1)
    send_csv(conn, data, headers: RefinementLog.headers(), filename: "#{year}-#{month}-refinements")
  end

  def send_csv(conn, stream, headers: headers, filename: filename) do
    {:ok, data} =
      Repo.transaction(fn _ ->
        stream
        |> CSV.encode(headers: headers)
        |> Enum.to_list()
      end)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=#{filename}.csv")
    |> send_resp(200, data)
  end
end
