defmodule EpiLocatorWeb.AdminSearchLiveTest do
  use EpiLocatorWeb.ConnCase

  import Phoenix.LiveViewTest

  alias EpiLocatorWeb.AdminSearchLive

  describe "person search with a result" do
    setup :register_and_log_in_admin

    setup %{test: test} do
      Mox.stub(TRClientBehaviourMock, :person_search, fn _ ->
        {:ok, "https://example.com/tr/api"}
      end)

      Mox.stub(TRClientBehaviourMock, :person_search_results, fn _ ->
        raw_body = File.read!("test/fixtures/thomson-reuters/person-search-get-response.xml")
        key = "{http://clear.thomsonreuters.com/api/search/2.0}PersonResultsPage"
        phone_results = raw_body |> XmlToMap.naive_map() |> Map.get(key)
        {:ok, phone_results}
      end)

      self = self()

      :ok =
        :telemetry.attach_many(
          "#{test}",
          [
            [:epi_locator, :tr, :admin_search, :success]
          ],
          fn name, measurements, metadata, _ ->
            send(self, {:telemetry_event, name, measurements, metadata})
          end,
          nil
        )

      :ok
    end

    test "it emits a telemetry event to record the number of search results", %{conn: conn} do
      {:ok, view, _mount_html} = live(conn, "/private/search")

      params = %{
        "first-name" => "John",
        "last-name" => "Doe",
        "street" => "100 Main Street",
        "city" => "San Francisco",
        "state" => "CA",
        "phone" => "4155555555",
        "zip-code" => "94113",
        "search-type" => "person",
        "dob" => "1980-01-01"
      }

      view |> element("form") |> render_submit(params)

      assert_receive {:telemetry_event, [:epi_locator, :tr, :admin_search, :success], %{},
                      %{
                        module: AdminSearchLive,
                        search_type: "person",
                        count: 1
                      }}
    end
  end

  describe "person search with an error" do
    setup :register_and_log_in_admin

    setup %{test: test} do
      Mox.stub(TRClientBehaviourMock, :person_search, fn _ ->
        {:error, "Bad times all round"}
      end)

      self = self()

      :ok =
        :telemetry.attach_many(
          "#{test}",
          [
            [:epi_locator, :tr, :admin_search, :error]
          ],
          fn name, measurements, metadata, _ ->
            send(self, {:telemetry_event, name, measurements, metadata})
          end,
          nil
        )

      :ok
    end

    test "it emits a telemetry event to record the error", %{conn: conn} do
      {:ok, view, _mount_html} = live(conn, "/private/search")

      params = %{
        "first-name" => "John",
        "last-name" => "Doe",
        "street" => "100 Main Street",
        "city" => "San Francisco",
        "state" => "CA",
        "phone" => "4155555555",
        "zip-code" => "94113",
        "search-type" => "person",
        "dob" => "1980-01-01"
      }

      view |> element("form") |> render_submit(params)

      assert_receive {:telemetry_event, [:epi_locator, :tr, :admin_search, :error], %{},
                      %{
                        search_type: "phone"
                      }}
    end
  end

  describe "phone search with a result" do
    setup :register_and_log_in_admin

    setup %{test: test} do
      Mox.stub(TRClientBehaviourMock, :phone_search, fn _ ->
        {:ok, "https://example.com/tr/api"}
      end)

      Mox.stub(TRClientBehaviourMock, :phone_search_results, fn _ ->
        raw_body = File.read!("test/fixtures/thomson-reuters/phone-search-get-response.xml")
        key = "{http://clear.thomsonreuters.com/api/search/2.0}PhoneResultsPage"
        phone_results = raw_body |> XmlToMap.naive_map() |> Map.get(key)
        {:ok, phone_results}
      end)

      self = self()

      :ok =
        :telemetry.attach_many(
          "#{test}",
          [
            [:epi_locator, :tr, :admin_search, :success]
          ],
          fn name, measurements, metadata, _ ->
            send(self, {:telemetry_event, name, measurements, metadata})
          end,
          nil
        )

      :ok
    end

    test "it emits a telemetry event to record the number of search results", %{conn: conn} do
      {:ok, view, _mount_html} = live(conn, "/private/search")

      params = %{
        "first-name" => "John",
        "last-name" => "Doe",
        "street" => "100 Main Street",
        "city" => "San Francisco",
        "state" => "CA",
        "phone" => "4155555555",
        "zip-code" => "94113",
        "search-type" => "phone",
        "dob" => "1980-01-01"
      }

      view |> element("form") |> render_submit(params)

      assert_receive {:telemetry_event, [:epi_locator, :tr, :admin_search, :success], %{},
                      %{
                        module: AdminSearchLive,
                        search_type: "phone",
                        count: 1
                      }}
    end
  end

  describe "phone search with an error" do
    setup :register_and_log_in_admin

    setup %{test: test} do
      Mox.stub(TRClientBehaviourMock, :phone_search, fn _ ->
        {:error, "Bad times all round"}
      end)

      self = self()

      :ok =
        :telemetry.attach_many(
          "#{test}",
          [
            [:epi_locator, :tr, :admin_search, :error]
          ],
          fn name, measurements, metadata, _ ->
            send(self, {:telemetry_event, name, measurements, metadata})
          end,
          nil
        )

      :ok
    end

    test "it emits a telemetry event to record the error", %{conn: conn} do
      {:ok, view, _mount_html} = live(conn, "/private/search")

      params = %{
        "first-name" => "John",
        "last-name" => "Doe",
        "street" => "100 Main Street",
        "city" => "San Francisco",
        "state" => "CA",
        "phone" => "4155555555",
        "zip-code" => "94113",
        "search-type" => "phone",
        "dob" => "1980-01-01"
      }

      view |> element("form") |> render_submit(params)

      assert_receive {:telemetry_event, [:epi_locator, :tr, :admin_search, :error], %{},
                      %{
                        search_type: "phone"
                      }}
    end
  end
end
