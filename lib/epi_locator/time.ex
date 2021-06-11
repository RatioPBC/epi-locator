defmodule EpiLocator.Time.Behaviour do
  @moduledoc "Provides a mockable behaviour for accessing current time"
  @callback utc_now() :: DateTime.t()
end

defmodule EpiLocator.Time.Real do
  @moduledoc "Implements the current time behaviour using DateTime"
  @behaviour EpiLocator.Time.Behaviour

  @impl EpiLocator.Time.Behaviour
  def utc_now, do: DateTime.utc_now()
end
