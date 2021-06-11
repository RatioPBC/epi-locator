defmodule EpiLocator.Search.PhoneNumber do
  @moduledoc false

  defstruct [
    :phone,
    :source,
    :id
  ]

  def new(search_result) do
    phone = search_result["PhoneNumber"]
    source = get_source(search_result["SourceInfo"])

    %__MODULE__{
      phone: phone,
      source: source,
      id: id(source, phone)
    }
  end

  def get_source(source_info) when is_list(source_info) do
    source_info
    |> Enum.map(& &1["SourceName"])
    |> Enum.uniq()
    |> Enum.sort()
  end

  def get_source(source_info), do: [source_info["SourceName"]]

  defp id(source, phone) do
    json = Jason.encode!(%{source: source, phone: phone})

    :sha256
    |> :crypto.hash(json)
    |> Base.encode64()
  end
end
