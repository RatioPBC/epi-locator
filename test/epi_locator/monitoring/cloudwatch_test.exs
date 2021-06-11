defmodule EpiLocator.Monitoring.CloudwatchTest do
  use ExUnit.Case, async: true

  alias EpiLocator.Monitoring.Cloudwatch

  describe "to_metric_data" do
    test "maps values to cloudwatch metric data" do
      result =
        %{
          "i.did.stuff" => 12,
          "and.some.things" => 9000
        }
        |> Cloudwatch.to_metric_data(type: "awesome")

      assert(
        result == [
          [metric_name: "and.some.things", value: 9000, dimensions: [{"Environment", :test}, {"Type", "awesome"}]],
          [metric_name: "i.did.stuff", value: 12, dimensions: [{"Environment", :test}, {"Type", "awesome"}]]
        ]
      )
    end

    test "uses config for Environment" do
      result =
        %{"yo" => 12}
        |> Cloudwatch.to_metric_data(type: "things")

      assert(
        result == [
          [metric_name: "yo", value: 12, dimensions: [{"Environment", :test}, {"Type", "things"}]]
        ]
      )
    end

    test "merges passed dimensions" do
      result =
        %{
          "i.did.stuff" => 12,
          "and.some.things" => 9000
        }
        |> Cloudwatch.to_metric_data(type: "awesome", dimensions: [{"Domain", "ny-essex"}])

      assert(
        result == [
          [metric_name: "and.some.things", value: 9000, dimensions: [{"Domain", "ny-essex"}, {"Environment", :test}, {"Type", "awesome"}]],
          [metric_name: "i.did.stuff", value: 12, dimensions: [{"Domain", "ny-essex"}, {"Environment", :test}, {"Type", "awesome"}]]
        ]
      )
    end
  end
end
