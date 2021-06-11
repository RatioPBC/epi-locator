defmodule EpiLocator.Search.PersonResult do
  @moduledoc """
  Parses person results from TR into a domain object for easier use
  """

  alias EpiLocator.Search.PhoneNumber

  defstruct ~w[
    email_addresses
    first_name
    last_name
    middle_name
    phone_numbers
    reported_date
    street
    city
    state
    zip_code
    dob
    id
    address
    address_hash
  ]a

  def new(search_result) do
    person_dominant_values = search_result["DominantValues"]["PersonDominantValues"]
    address = person_dominant_values["Address"]
    name = person_dominant_values["Name"]
    additional_phone_numbers = search_result["RecordDetails"]["PersonResponseDetail"]["AdditionalPhoneNumbers"]
    phone_numbers = phones(additional_phone_numbers)
    email_addresses = search_result["RecordDetails"]["PersonResponseDetail"]["EmailAddress"] |> email_addresses()
    dob = person_dominant_values["AgeInfo"]["PersonBirthDate"]
    full_address = address(address)

    %__MODULE__{
      email_addresses: email_addresses,
      first_name: name["FirstName"],
      last_name: name["LastName"],
      middle_name: name["MiddleName"],
      phone_numbers: phone_numbers,
      # Ideally, the reported_date should be stored as a Date
      # we're currently only using it for display purposes, so let's keep it a string for now:
      reported_date: address["ReportedDate"] |> safe(),
      city: city_from(address),
      state: state_from(address),
      zip_code: zip_code_from(address),
      street: street_from(address),
      dob: format_dob(dob),
      id: id(search_result),
      address: full_address,
      address_hash: hash(full_address)
    }
  end

  defp address(address) do
    street = street_from(address)
    city = city_from(address)
    state = state_from(address)
    zip_code = zip_code_from(address)
    "#{street}, #{city}, #{state} #{zip_code}"
  end

  defp city_from(address), do: safe_address_component(address, "City")
  defp state_from(address), do: safe_address_component(address, "State")
  defp street_from(address), do: safe_address_component(address, "Street")
  defp zip_code_from(address), do: safe_address_component(address, "ZipCode")

  defp safe_address_component(address, property), do: address[property] |> safe()

  defp safe(nil), do: nil
  defp safe(%{}), do: nil
  defp safe(value), do: value

  @no_dob "Unavailable"
  def unavailable_dob_string(), do: @no_dob
  defp format_dob(nil), do: unavailable_dob_string()
  defp format_dob(""), do: unavailable_dob_string()
  defp format_dob(dob), do: dob

  defp phones(additional_phone_numbers) when is_list(additional_phone_numbers) do
    additional_phone_numbers
    |> Enum.map(&PhoneNumber.new(&1))
  end

  defp phones(additional_phone_numbers), do: [PhoneNumber.new(additional_phone_numbers)]

  defp email_addresses(email_addresses) when is_list(email_addresses), do: email_addresses
  defp email_addresses(nil), do: []
  defp email_addresses(email_address), do: [email_address]

  defp id(search_result) do
    search_result
    |> Jason.encode!()
    |> hash()
  end

  defp hash(message), do: :sha256 |> :crypto.hash(message) |> Base.encode64()
end
