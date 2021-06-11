defmodule EpiLocator.LookupApiBehaviour do
  @callback lookup_person(Keyword.t()) :: {:ok, String.t()} | {:error, String.t()}
end
