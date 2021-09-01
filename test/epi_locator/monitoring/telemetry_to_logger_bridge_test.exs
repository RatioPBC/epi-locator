defmodule EpiLocator.Monitoring.TelemetryToLoggerBridgeTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias EpiLocator.Monitoring.TelemetryToLoggerBridge

  setup do
    TelemetryToLoggerBridge.setup()
    on_exit(fn -> :telemetry.detach(TelemetryToLoggerBridge.telemetry_handler_id()) end)
  end

  describe "successful search" do
    test "creates the correct log message" do
      assert capture_log([level: :info], fn ->
               :telemetry.execute([:epi_locator, :tr, :search, :success], %{}, %{
                 case_id: "fixture-case-id",
                 count: 42,
                 domain: "fixture-domain",
                 module: "EmittingModule",
                 user: "fixture-user"
               })
             end) =~ "[EmittingModule] User[fixture-user] Case[fixture-case-id] Domain[fixture-domain] received 42 search results returned from Thomson Reuters"
    end
  end
end
