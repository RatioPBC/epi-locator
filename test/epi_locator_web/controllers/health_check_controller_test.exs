defmodule EpiLocatorWeb.HealthCheckControllerTest do
  use EpiLocatorWeb.ConnCase, async: true

  alias EpiLocator.HTTPoisonMock

  import Mox

  setup :verify_on_exit!

  describe "index" do
    test "is ok", context do
      conn = get(context.conn, Routes.health_check_path(@endpoint, :index))
      assert text_response(conn, 200) =~ "OK"
    end
  end

  describe "commcare" do
    test "success", context do
      expect(HTTPoisonMock, :get, fn "https://www.commcarehq.org/accounts/login/" ->
        {:ok, %HTTPoison.Response{status_code: 200, body: ""}}
      end)

      conn = get(context.conn, Routes.health_check_path(@endpoint, :commcare))
      assert text_response(conn, 200) =~ "OK"
    end

    test "failure", context do
      expect(HTTPoisonMock, :get, fn "https://www.commcarehq.org/accounts/login/" ->
        {:ok, %HTTPoison.Response{status_code: 404, body: ""}}
      end)

      conn = get(context.conn, Routes.health_check_path(@endpoint, :commcare))
      assert text_response(conn, 500) =~ "Cannot ping CommCare"
    end
  end
end
