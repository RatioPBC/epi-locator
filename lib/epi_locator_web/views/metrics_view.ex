defmodule EpiLocatorWeb.MetricsView do
  use Timex
  use EpiLocatorWeb, :view

  # eventually someone may want to make this a configuration variable,
  # but for now it is hardcoded because yagni
  @launch ~D[2020-12-01]
  def months_since_launch() do
    Interval.new(
      from: @launch,
      until: Timex.today(),
      step: [months: 1]
    )
    |> Enum.to_list()
    |> Enum.reverse()
  end
end
