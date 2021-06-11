defmodule EpiLocator.Monitoring.TelemetryToMetricsBridgeTest do
  use ExUnit.Case, async: false

  import Mox

  alias EpiLocator.Monitoring.TelemetryToMetricsBridge

  setup :verify_on_exit!

  setup do
    TelemetryToMetricsBridge.setup()
    on_exit(fn -> :telemetry.detach(TelemetryToMetricsBridge.telemetry_handler_id()) end)
  end

  describe "admin search error metrics" do
    test "sends the correct data to the metrics api" do
      Mox.expect(MetricsAPIBehaviourMock, :send, 1, fn metrics, keywords ->
        assert %{"tr.admin_search.error.count" => 1} = metrics
        assert [type: "TR Search"] = keywords
      end)

      :telemetry.execute([:epi_locator, :tr, :admin_search, :error], %{}, %{search_type: "phone"})
    end
  end

  describe "admin search success metrics" do
    test "sends the correct data to the metrics api" do
      Mox.expect(MetricsAPIBehaviourMock, :send, 1, fn metrics, keywords ->
        assert %{"tr.admin_search.success.count" => 1} = metrics
        assert %{"tr.admin_search.results.count" => 42} = metrics
        assert [type: "TR Search"] = keywords
      end)

      :telemetry.execute([:epi_locator, :tr, :admin_search, :success], %{}, %{count: 42, module: "EmittingModule"})
    end
  end

  describe "search error metrics" do
    test "sends the correct data to the metrics api" do
      expected_domain = "fixture-domain"
      expected_case_type = "fixture-patient-type"

      Mox.expect(MetricsAPIBehaviourMock, :send, 1, fn metrics, keywords ->
        assert %{"tr.search.error.count" => 1} = metrics
        assert [type: "TR Search", dimensions: [{"Domain", ^expected_domain}]] = keywords
      end)

      Mox.expect(MetricsAPIBehaviourMock, :send, 1, fn metrics, keywords ->
        assert %{"tr.search.error.count" => 1} = metrics
        assert [type: "TR Search", dimensions: [{"CaseType", ^expected_case_type}]] = keywords
      end)

      Mox.expect(MetricsAPIBehaviourMock, :send, 1, fn metrics, keywords ->
        assert %{"tr.search.error.count" => 1} = metrics
        assert [type: "TR Search"] = keywords
      end)

      :telemetry.execute([:epi_locator, :tr, :search, :error], %{}, %{case_id: "fixture-case-id", domain: expected_domain, case_type: expected_case_type, module: "EmittingModule", user: "fixture-user"})
    end
  end

  describe "search no results metrics" do
    test "sends the correct data to the metrics api" do
      expected_domain = "fixture-domain"
      expected_case_type = "fixture-patient-type"

      Mox.expect(MetricsAPIBehaviourMock, :send, 1, fn metrics, keywords ->
        assert %{"tr.search.no_results.count" => 1} = metrics
        assert [type: "TR Search", dimensions: [{"Domain", ^expected_domain}]] = keywords
      end)

      Mox.expect(MetricsAPIBehaviourMock, :send, 1, fn metrics, keywords ->
        assert %{"tr.search.no_results.count" => 1} = metrics
        assert [type: "TR Search", dimensions: [{"CaseType", ^expected_case_type}]] = keywords
      end)

      Mox.expect(MetricsAPIBehaviourMock, :send, 1, fn metrics, keywords ->
        assert %{"tr.search.no_results.count" => 1} = metrics
        assert [type: "TR Search"] = keywords
      end)

      :telemetry.execute([:epi_locator, :tr, :search, :no_results], %{}, %{
        case_id: "fixture-case-id",
        domain: expected_domain,
        case_type: expected_case_type,
        module: "EmittingModule",
        user: "fixture-user"
      })
    end
  end

  describe "search success metrics" do
    test "sends the correct data to the metrics api" do
      expected_domain = "fixture-domain"
      expected_case_type = "fixture-patient-type"

      Mox.expect(MetricsAPIBehaviourMock, :send, 1, fn metrics, keywords ->
        assert %{"tr.search.success.count" => 1, "tr.search.results.count" => 42} = metrics
        assert [type: "TR Search", dimensions: [{"Domain", ^expected_domain}]] = keywords
      end)

      Mox.expect(MetricsAPIBehaviourMock, :send, 1, fn metrics, keywords ->
        assert %{"tr.search.success.count" => 1, "tr.search.results.count" => 42} = metrics
        assert [type: "TR Search", dimensions: [{"CaseType", ^expected_case_type}]] = keywords
      end)

      Mox.expect(MetricsAPIBehaviourMock, :send, 1, fn metrics, keywords ->
        assert %{"tr.search.success.count" => 1, "tr.search.results.count" => 42} = metrics
        assert [type: "TR Search"] = keywords
      end)

      :telemetry.execute([:epi_locator, :tr, :search, :success], %{}, %{
        case_id: "fixture-case-id",
        domain: expected_domain,
        case_type: expected_case_type,
        count: 42,
        module: "EmittingModule",
        user: "fixture-user"
      })
    end
  end
end
