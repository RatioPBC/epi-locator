defmodule EpiLocator.Search.PhoneResult do
  @moduledoc """
  Parses phone results from TR into a domain object for easier use
  """

  defstruct [
    :phone_number,
    :street,
    :city,
    :state,
    :zip_code
  ]

  def new(search_result) do
    phone_dominant_values = search_result["DominantValues"]["PhoneDominantValues"]
    address = phone_dominant_values["Address"]

    %__MODULE__{
      phone_number: phone_dominant_values["PhoneNumber"] |> safe(),
      city: address["City"] |> safe(),
      state: address["State"] |> safe(),
      zip_code: address["ZipCode"] |> safe(),
      street: address["Street"] |> safe()
    }
  end

  defp safe(nil), do: nil
  defp safe(%{}), do: nil
  defp safe(value), do: value
end
