defmodule EpiLocatorWeb.Plugs.RequireValidSignatureTest do
  use EpiLocatorWeb.ConnCase, async: true

  import Mox
  alias EpiLocator.Signature.Cache
  alias EpiLocatorWeb.Plugs.RequireValidSignature
  alias Phoenix.ConnTest
  @opts []

  setup do
    on_exit(fn ->
      {:ok, _} = Cache.clear()
    end)
  end

  describe "call/2" do
    test "halts when signature is invalid" do
      expect(EpiLocator.SignatureMock, :valid?, fn _, _, _ ->
        {:error, :invalid}
      end)

      conn =
        :post
        |> Phoenix.ConnTest.build_conn("/", signature: "some-sig")
        |> RequireValidSignature.call(@opts)

      assert conn.halted
      assert conn.status == 403
      assert conn.resp_body == "Invalid signature"
    end

    test "halts when signature has been used" do
      signature = "some-generated-signature"
      Cache.put(signature, signature)

      conn =
        :post
        |> Phoenix.ConnTest.build_conn("/", signature: signature)
        |> RequireValidSignature.call(@opts)

      assert conn.halted
      assert conn.status == 403
      assert conn.resp_body == "Signature already used"
    end

    test "redirects when signature is valid" do
      expect(EpiLocator.SignatureMock, :valid?, fn _, _, _ ->
        :ok
      end)

      path = "search"
      signature = "some-sig"
      variables = "user-id=1&path=#{path}"

      conn =
        :post
        |> Phoenix.ConnTest.build_conn("/", signature: signature, variables: variables)
        |> Phoenix.ConnTest.init_test_session(%{})
        |> RequireValidSignature.call(@opts)

      {:ok, true} = Cache.exists?(signature)

      refute conn.halted
      assert ConnTest.redirected_to(conn, 302) == "/#{path}?#{variables}"
    end
  end

  test "get_user_id/1" do
    variables = "case-id=abcd-1234&domain=westchester&user-id=4321"
    conn = Phoenix.ConnTest.build_conn(:post, "/", variables: variables)

    assert RequireValidSignature.get_user_id(conn) == "4321"
  end

  test "get_query_string/1" do
    variables = "case-id=abcd-1234&domain=westchester&user-id=4321"

    actual_variables =
      :post
      |> Phoenix.ConnTest.build_conn("/", variables: variables)
      |> RequireValidSignature.get_query_string()

    assert actual_variables == variables
  end

  describe "get_path/1" do
    test "prepends a / when first character is not already /" do
      variables = "case-id=abcd-1234&domain=westchester&user-id=4321&path=hello"
      conn = Phoenix.ConnTest.build_conn(:post, "/", variables: variables)

      assert RequireValidSignature.get_path(conn) == "/hello"
    end

    test "returns path unmodified when path starts with /" do
      variables = "case-id=abcd-1234&domain=westchester&user-id=4321&path=/hello"
      conn = Phoenix.ConnTest.build_conn(:post, "/", variables: variables)

      assert RequireValidSignature.get_path(conn) == "/hello"
    end
  end

  test "get_signature/1" do
    signature = "some-sig"
    conn = Phoenix.ConnTest.build_conn(:post, "/", signature: signature)

    assert RequireValidSignature.get_signature(conn) == signature
  end
end
