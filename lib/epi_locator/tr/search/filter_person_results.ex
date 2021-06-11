defmodule EpiLocator.Search.FilterPersonResults do
  alias EpiLocator.Search.PersonResult

  def filter(person_results, filters) do
    regular_filters = Map.drop(filters, ~w{phone dob}a)

    person_results
    |> apply_regular_filters(regular_filters)
    |> apply_phone_filter(filters[:phone])
    |> apply_dob_filter(filters[:dob])
  end

  # # #

  defp apply_dob_filter(search_results, nil), do: search_results
  defp apply_dob_filter(search_results, dob), do: search_results |> Enum.filter(&dob_filter(&1, dob))

  defp apply_phone_filter(search_results, nil), do: search_results

  defp apply_phone_filter(search_results, filter_phone) do
    normalized_filter_phone = normalize_phone(filter_phone)

    Enum.filter(search_results, fn search_result ->
      Enum.any?(search_result.phone_numbers, fn
        %{phone: phone} -> (normalize_phone(phone) || "") |> String.starts_with?(normalized_filter_phone)
      end)
    end)
  end

  defp apply_regular_filters(search_results, filters) do
    Enum.filter(search_results, fn search_result ->
      Enum.all?(filters, fn {key, value} ->
        up_value = String.upcase(value || "")

        search_result
        |> Map.get(key)
        |> upcase()
        |> String.starts_with?(up_value)
      end)
    end)
  end

  defp upcase(nil), do: ""
  defp upcase(string) when is_binary(string), do: String.upcase(string)

  defp dob_filter(search_result, filter) do
    unavailable_string = PersonResult.unavailable_dob_string()

    case search_result.dob do
      ^unavailable_string -> false
      nil -> false
      _ -> matches_dob?(search_result.dob, filter)
    end
  end

  defp matches_dob?(dob, filter) do
    case String.split(dob, "/") do
      components = [_month, _day, _year] -> matches_dob_components?(components, [:month, :day, :year], filter)
      components = [_month, _year] -> matches_dob_components?(components, [:month, :year], filter)
      [year] -> matches_dob_component?(year, Map.get(filter, :year))
    end
  end

  defp matches_dob_components?(components, fields, filter) do
    fields
    |> Enum.zip(components)
    |> Enum.all?(fn {field, value} -> matches_dob_component?(value, Map.get(filter, field)) end)
  end

  defp matches_dob_component?(_component, nil), do: true
  defp matches_dob_component?("XX", _filter_value), do: true
  defp matches_dob_component?("XXXX", _filter_value), do: true
  defp matches_dob_component?(nil, _filter_value), do: true
  defp matches_dob_component?(component, filter_value), do: component == filter_value

  defp normalize_phone(nil), do: nil

  defp normalize_phone(phone) do
    numeric_phone = Regex.replace(~r/[^0-9]/, phone, "")
    Regex.replace(~r/^1/, numeric_phone, "")
  end
end
