defmodule EpiLocator.System.Behaviour do
  @moduledoc "Provides a mockable behaviour for accessing monotonic time"
  @callback monotonic_time(atom()) :: integer()
end

defmodule EpiLocator.System.Real do
  @moduledoc "Implements the system monotonic_time behaviour using System"
  @behaviour EpiLocator.System.Behaviour

  @impl EpiLocator.System.Behaviour
  def monotonic_time(unit), do: System.monotonic_time(unit)
end
