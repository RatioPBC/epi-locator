defmodule EpiLocator.TRClientTest do
  use EpiLocator.DataCase, async: false

  import Mox
  import ExUnit.CaptureLog

  alias EpiLocator.HTTPoisonMock
  alias EpiLocator.TRClient

  setup :set_mox_global
  setup :verify_on_exit!
  setup :tr_enabled

  @expected_headers ["content-type": "application/xml", Authorization: "Basic faked-base64-encoded-basic-auth"]
  @expected_person_search_url "https://s2s.beta.thomsonreuters.com/api/v3/person/searchResults"

  # From the value inside of: test/fixtures/thomson-reuters/person-search-post-response.xml:
  @expected_url_for_person_search_results "#{@expected_person_search_url}/00000000733671e20173494ef23b34b5"

  describe "person_search POST" do
    setup do
      expect(HTTPoisonMock, :post, fn url, _body, headers, _options ->
        assert headers == @expected_headers
        assert url == @expected_person_search_url
        body = File.read!("test/fixtures/thomson-reuters/person-search-post-response.xml")
        {:ok, %HTTPoison.Response{status_code: 200, body: body}}
      end)

      :ok
    end

    test "returns some XML which has the search result URL" do
      {:ok, results_uri} =
        TRClient.person_search(
          first_name: "Eric",
          last_name: "Sample-Document",
          street: "4010 Cinnabar Drive",
          city: "Eagan",
          state: "MN",
          phone: "612-555-8910",
          zip_code: "",
          dob: nil
        )

      assert results_uri == "#{@expected_person_search_url}/00000000733671e20173494ef23b34b5"
    end
  end

  describe "person_search POST - no results URL returned" do
    setup do
      expect(HTTPoisonMock, :post, fn url, _body, headers, _options ->
        assert headers == @expected_headers
        assert url == @expected_person_search_url
        body = File.read!("test/fixtures/thomson-reuters/person-search-post-response_no-results.xml")
        {:ok, %HTTPoison.Response{status_code: 200, body: body}}
      end)

      :ok
    end

    test "returns an error" do
      response =
        TRClient.person_search(
          first_name: "Eric",
          last_name: "Sample-Document",
          street: "4010 Cinnabar Drive",
          city: "Eagan",
          state: "MN",
          phone: "612-555-8910",
          zip_code: "",
          dob: nil
        )

      assert response == {:error, :no_results, "no search results URL returned from Thomson Reuters"}
    end
  end

  describe "person_search POST - something other than a 200 was returned from TR" do
    setup do
      expect(HTTPoisonMock, :post, fn _url, _headers, _body, _options ->
        {:ok, %HTTPoison.Response{status_code: 402, body: "something bad happened"}}
      end)

      :ok
    end

    test "returns an error with the status code" do
      assert capture_log(fn ->
               response =
                 TRClient.person_search(
                   first_name: "Eric",
                   last_name: "Sample-Document",
                   street: "4010 Cinnabar Drive",
                   city: "Eagan",
                   state: "MN",
                   phone: "612-555-8910",
                   zip_code: "",
                   dob: nil
                 )

               assert response == {:error, "Status code 402 returned from Thomson Reuters.  Body: something bad happened"}
             end) =~ "[error] Status code 402 returned from Thomson Reuters.  Body: something bad happened"
    end
  end

  describe "person_search GET results" do
    setup do
      expect(HTTPoisonMock, :get, fn url, headers, _http_options ->
        assert headers == @expected_headers
        assert url == @expected_url_for_person_search_results
        body = File.read!("test/fixtures/thomson-reuters/person-search-get-response.xml")
        {:ok, %HTTPoison.Response{status_code: 200, body: body}}
      end)

      :ok
    end

    test "returns some XML which has the results of the prior search" do
      results_uri = "#{@expected_person_search_url}/00000000733671e20173494ef23b34b5"

      {:ok, results} = TRClient.person_search_results(results_uri)

      assert results["EndIndex"] == "0"
    end
  end

  describe "person_search GET results - something other than a 200 was returned from TR" do
    setup do
      expect(HTTPoisonMock, :get, fn _url, _headers, _options ->
        {:ok, %HTTPoison.Response{status_code: 402, body: "something went horribly wrong"}}
      end)

      :ok
    end

    test "returns an error message" do
      results_uri = "#{@expected_person_search_url}/00000000733c12ed017358ac5ef44463"

      assert capture_log(fn ->
               response = TRClient.person_search_results(results_uri)
               assert response == {:error, "Status code 402 returned from Thomson Reuters.  Body: something went horribly wrong"}
             end) =~ "[error] Status code 402 returned from Thomson Reuters.  Body: something went horribly wrong"
    end
  end

  describe "person_search_body/1" do
    setup context do
      first_name = "Some FN"
      last_name = "Some LN"
      street = "123 Some Street"
      city = "An City"
      state = "Great State"
      phone = "000-555-1212"
      dob = "ignored"

      opts = [
        first_name: first_name,
        last_name: last_name,
        street: street,
        city: city,
        state: state,
        phone: phone,
        zip_code: context.zip_code,
        dob: dob
      ]

      [opts: opts]
    end

    @tag zip_code: "00001"
    test "generates XML with a legit zip code", %{opts: opts} do
      xml = TRClient.person_search_body(opts)

      assert xml =~ opts[:first_name]
      assert xml =~ opts[:last_name]
      assert xml =~ opts[:street]
      assert xml =~ opts[:city]
      assert xml =~ opts[:state]
      refute xml =~ opts[:phone]
      assert xml =~ opts[:zip_code]
      refute xml =~ opts[:dob]
    end

    @tag zip_code: "00000"
    test "generates XML with no zip code", %{opts: opts} do
      xml = TRClient.person_search_body(opts)

      assert xml =~ opts[:first_name]
      assert xml =~ opts[:last_name]
      assert xml =~ opts[:street]
      assert xml =~ opts[:city]
      assert xml =~ opts[:state]
      refute xml =~ opts[:phone]
      refute xml =~ opts[:zip_code]
      refute xml =~ opts[:dob]
      assert xml =~ ~r{<ZipCode></ZipCode>}
    end
  end

  describe "format_date/1" do
    test "returns stars when given a nil" do
      assert TRClient.format_date(nil) == "**/**/****"
    end

    test "returns MM/DD/YYYY for a Date" do
      assert TRClient.format_date(~D[2020-02-28]) == "02/28/2020"
    end

    test "returns whatever string it was given" do
      assert TRClient.format_date("foo") == "foo"
    end
  end

  defp tr_enabled(context) do
    {:ok, true} = FunWithFlags.enable(TRClient.flag_name())

    {:ok, context}
  end
end
