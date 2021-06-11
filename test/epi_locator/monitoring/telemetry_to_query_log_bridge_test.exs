defmodule EpiLocator.Monitoring.TelemetryToQueryLogBridgeTest do
  use EpiLocator.DataCase, async: false

  alias EpiLocator.Monitoring.TelemetryToQueryLogBridge
  alias EpiLocator.QueryResultLog
  alias EpiLocator.Repo

  @expected_domain "fixture-domain"
  @expected_case_type "fixture-patient-type"
  @expected_user Ecto.UUID.generate()
  @expected_timestamp ~U[2021-02-23 21:40:25Z]
  setup do
    TelemetryToQueryLogBridge.setup()
    on_exit(fn -> :telemetry.detach(TelemetryToQueryLogBridge.telemetry_handler_id()) end)
  end

  describe "successful search query logging" do
    test "logs the details of the successful search" do
      :telemetry.execute([:epi_locator, :tr, :search, :success], %{}, %{
        case_id: "fixture-case-id",
        case_type: @expected_case_type,
        count: 42,
        domain: @expected_domain,
        module: "EmittingModule",
        msec_elapsed: 420,
        search_type: "phone",
        timestamp: @expected_timestamp,
        user: @expected_user
      })

      assert [
               %{case_type: @expected_case_type, domain: @expected_domain, msec_elapsed: 420, results: 42, success: true, timestamp: @expected_timestamp, user: @expected_user}
             ] = Repo.all(QueryResultLog)
    end
  end

  describe "no results search query logging" do
    test "logs the details of the no results search" do
      :telemetry.execute([:epi_locator, :tr, :search, :no_results], %{}, %{
        case_type: @expected_case_type,
        domain: @expected_domain,
        msec_elapsed: 420,
        module: "EmittingModule",
        search_type: "phone",
        timestamp: @expected_timestamp,
        user: @expected_user
      })

      assert [
               %{case_type: @expected_case_type, domain: @expected_domain, msec_elapsed: 420, results: 0, success: true, timestamp: @expected_timestamp, user: @expected_user}
             ] = Repo.all(QueryResultLog)
    end
  end

  describe "error search query logging" do
    test "logs the details of the erroneous search" do
      :telemetry.execute([:epi_locator, :tr, :search, :error], %{}, %{
        domain: @expected_domain,
        case_type: @expected_case_type,
        msec_elapsed: 420,
        module: "EmittingModule",
        search_type: "phone",
        timestamp: @expected_timestamp,
        user: @expected_user
      })

      assert [
               %{case_type: @expected_case_type, domain: @expected_domain, results: 0, success: false, timestamp: @expected_timestamp, msec_elapsed: 420, user: @expected_user}
             ] = Repo.all(QueryResultLog)
    end
  end
end
