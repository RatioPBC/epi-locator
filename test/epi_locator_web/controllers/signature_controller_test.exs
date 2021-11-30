defmodule EpiLocatorWeb.SignatureControllerTest do
  use EpiLocatorWeb.ConnCase, async: true
  import Mox

  describe "verify" do
    test "asdf", %{conn: conn} do
      expect(EpiLocator.SignatureMock, :valid?, fn _, _, _ ->
        {:error, :invalid}
      end)

      conn = post(conn, Routes.signature_path(conn, :index), %{"path" => "/", "signature" => "some-sig"})

      assert conn.halted
      assert conn.state == :sent
    end
  end
end
