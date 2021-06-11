defmodule EpiLocatorWeb.MetricsControllerTest do
  use EpiLocatorWeb.ConnCase, async: true
  alias EpiLocator.{Repo, QueryResultLog, RefinementLog}

  describe "metrics authorized" do
    setup :register_and_log_in_admin

    test "/metrics/all/year/month", %{conn: conn} do
      year = 2020
      month = 12

      create_qlr(
        case_type: "patient",
        domain: "domain",
        results: 30,
        success: true,
        timestamp: ~U[2020-12-15 00:50:00Z],
        msec_elapsed: 10,
        user: "me"
      )

      create_qlr(
        case_type: "patient",
        domain: "domain",
        results: 30,
        success: true,
        timestamp: ~U[2020-11-15 00:50:00Z]
        # not in the same month
      )

      create_qlr(
        case_type: "patient",
        domain: "domain",
        results: 0,
        success: false,
        timestamp: ~U[2020-12-15 00:00:00Z],
        msec_elapsed: 100,
        user: "you"
      )

      conn = get(conn, "/metrics/#{year}/#{month}/all")
      assert response_content_type(conn, :csv)
      assert get_resp_header(conn, "content-disposition") == ["attachment; filename=2020-12-all.csv"]

      assert response(conn, 200) ==
               """
               case_type,domain,results,success,timestamp,msec_elapsed,user
               patient,domain,30,true,2020-12-15 00:50:00Z,10,me
               patient,domain,0,false,2020-12-15 00:00:00Z,100,you
               """
               |> String.replace("\n", "\r\n")
    end

    test "/metrics/year/month/refinements/all", %{conn: conn} do
      year = 2020
      month = 12

      create_rl(
        case_type: "patient",
        domain: "domain",
        total_results: 30,
        refined_results: 10,
        timestamp: ~U[2020-12-15 00:50:00Z],
        user: "me",
        last_name: true
      )

      create_rl(
        case_type: "patient",
        domain: "domain",
        total_results: 30,
        refined_results: 29,
        timestamp: ~U[2020-11-15 00:50:00Z],
        user: "me"
      )

      create_rl(
        case_type: "patient",
        domain: "domain",
        total_results: 100,
        refined_results: 95,
        timestamp: ~U[2020-12-15 00:00:00Z],
        user: "you",
        dob: true,
        state: true
      )

      conn = get(conn, "/metrics/#{year}/#{month}/refinements/all")
      assert response_content_type(conn, :csv)
      assert get_resp_header(conn, "content-disposition") == ["attachment; filename=2020-12-refinements.csv"]

      assert response(conn, 200) ==
               """
               case_type,domain,timestamp,user,total_results,refined_results,first_name,last_name,dob,phone,city,state
               patient,domain,2020-12-15 00:50:00Z,me,30,10,false,true,false,false,false,false
               patient,domain,2020-12-15 00:00:00Z,you,100,95,false,false,true,false,false,true
               """
               |> String.replace("\n", "\r\n")

      conn = get(conn, "/metrics/#{year}/#{month}/refinements/summaries")
      assert response_content_type(conn, :csv)
      assert get_resp_header(conn, "content-disposition") == ["attachment; filename=2020-12-refinement-summaries.csv"]

      assert response(conn, 200) ==
               """
               week_of,case_type,domain,total_refinements,unique_users,first_name,last_name,dob,phone,city,state
               12/14/2020,patient,domain,2,2,0,1,1,0,0,1
               """
               |> String.replace("\n", "\r\n")
    end
  end

  defp create_qlr(params) do
    %QueryResultLog{}
    |> QueryResultLog.changeset(Map.new(params))
    |> Repo.insert!()
  end

  defp create_rl(params) do
    %RefinementLog{}
    |> RefinementLog.changeset(Map.new(params))
    |> Repo.insert!()
  end
end
