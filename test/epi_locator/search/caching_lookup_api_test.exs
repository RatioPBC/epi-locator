defmodule EpiLocator.Search.CachingLookupApiTest do
  use ExUnit.Case, async: true

  import Mox

  alias EpiLocator.Search.CachingLookupApi
  alias EpiLocator.Search.Cache

  setup do
    on_exit(fn ->
      {:ok, _} = Cache.clear()
    end)
  end

  describe ".lookup_person" do
    test "it uses the lookup api to fetch enrichment data based on the provided person data" do
      person_data = %{}
      expect(LookupApiBehaviourMock, :lookup_person, 1, fn ^person_data -> {:ok, :enrichment_data} end)

      assert {:ok, :enrichment_data} = CachingLookupApi.lookup_person("case_id", person_data)
    end

    test "it caches the enriched data" do
      person_data = %{}
      expect(LookupApiBehaviourMock, :lookup_person, 1, fn ^person_data -> {:ok, :enrichment_data} end)

      CachingLookupApi.lookup_person("case_id", person_data)
      verify!()

      assert {:ok, :enrichment_data} = CachingLookupApi.lookup_person("case_id", person_data)
    end

    test "it uses a combination of case id and person data to cache the enriched data" do
      person_data = %{}
      pepper = "pepper"
      expect(LookupApiBehaviourMock, :lookup_person, 0, fn ^person_data -> nil end)
      {:ok, key} = CachingLookupApi.cache_key("case_id", person_data, pepper)
      Cache.put(key, :enrichment_data)

      assert {:ok, :enrichment_data} = CachingLookupApi.lookup_person("case_id", person_data, pepper)
    end

    test "it doesn't cache when the lookup api fails" do
      person_data = %{}
      pepper = "pepper"

      expect(LookupApiBehaviourMock, :lookup_person, 2, fn _ -> {:error, :something_bad} end)

      assert {:error, :something_bad} = CachingLookupApi.lookup_person("case_id", person_data, pepper)
      assert {:error, :something_bad} = CachingLookupApi.lookup_person("case_id", person_data, pepper)
    end
  end

  describe "cache_key" do
    test "combines case_id with person data into a hash" do
      pepper = "pepper"
      case_id = "case_id"
      other_case_id = "other_case_id"

      person_data = [
        first_name: "first_name",
        last_name: "last_name",
        street: "street",
        city: "city",
        state: "state",
        phone: "phone",
        zip_code: "zip_code",
        dob: "dob"
      ]

      other_person_data = [
        first_name: "other_first_name",
        last_name: "other_last_name",
        street: "other_street",
        city: "other_city",
        state: "other_state",
        phone: "other_phone",
        zip_code: "other_zip_code",
        dob: "other_dob"
      ]

      assert_cache_key(%{case_id: case_id, person_data: person_data, pepper: pepper}, %{case_id: case_id, person_data: person_data, pepper: pepper})
      assert_cache_key(%{case_id: other_case_id, person_data: other_person_data, pepper: pepper}, %{case_id: other_case_id, person_data: other_person_data, pepper: pepper})
      refute_cache_key(%{case_id: case_id, person_data: other_person_data, pepper: pepper}, %{case_id: case_id, person_data: person_data, pepper: pepper})
      refute_cache_key(%{case_id: other_case_id, person_data: person_data, pepper: pepper}, %{case_id: case_id, person_data: person_data, pepper: pepper})
    end

    defp assert_cache_key(a, b) do
      {:ok, left} = CachingLookupApi.cache_key(a.case_id, a.person_data, a.pepper)
      {:ok, right} = CachingLookupApi.cache_key(b.case_id, b.person_data, b.pepper)
      assert left == right
    end

    defp refute_cache_key(a, b) do
      {:ok, left} = CachingLookupApi.cache_key(a.case_id, a.person_data, a.pepper)
      {:ok, right} = CachingLookupApi.cache_key(b.case_id, b.person_data, b.pepper)
      refute left == right
    end

    test "uses date as dob in key" do
      case_id = "dob_case_id"
      pepper = "some-pepper"

      person_data = [
        first_name: "other_first_name",
        last_name: "other_last_name",
        street: "other_street",
        city: "other_city",
        state: "other_state",
        phone: "other_phone",
        zip_code: "other_zip_code",
        dob: ~D[2020-10-31]
      ]

      {:ok, key} = CachingLookupApi.cache_key(case_id, person_data, pepper)
      assert String.length(key) > 10
    end

    test "cache keys do not contain PII" do
      case_id = "case_id"

      person_data = [
        first_name: "first_name",
        last_name: "last_name",
        street: "street",
        city: "city",
        state: "state",
        phone: "phone",
        zip_code: "zip_code",
        dob: "dob"
      ]

      {:ok, key} = CachingLookupApi.cache_key(case_id, person_data, "pepper")

      for {_key, pii} <- person_data do
        refute key =~ pii
      end
    end

    test "it uses the pepper" do
      case_id = "case_id"

      person_data = [
        first_name: "first_name",
        last_name: "last_name",
        street: "street",
        city: "city",
        state: "state",
        phone: "phone",
        zip_code: "zip_code",
        dob: "dob"
      ]

      refute CachingLookupApi.cache_key(case_id, person_data, "habenero") == CachingLookupApi.cache_key(case_id, person_data, "jalapeno")
    end
  end
end
