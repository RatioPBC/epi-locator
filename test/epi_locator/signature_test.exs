defmodule EpiLocator.SignatureTest do
  use ExUnit.Case, async: true
  require Phoenix.ConnTest
  alias EpiLocator.Signature
  import Euclid.Assertions
  import Mox

  setup :set_mox_from_context

  describe "valid?/1" do
    setup do
      api_key = "blahblah"
      secret = "shhhhhhhh"
      ref_time = DateTime.utc_now()
      stub(EpiLocator.TimeMock, :utc_now, fn -> ref_time end)

      %{api_key: api_key, secret: secret, ref_time: ref_time}
    end

    test "returns :ok for valid conn, with a valid timestamp", %{api_key: api_key, secret: secret, ref_time: ref_time} do
      timestamp = ref_time |> DateTime.to_unix() |> subtract(9) |> Integer.to_string()
      conn = get_conn(api_key, secret, timestamp)
      assert Signature.valid?(conn, api_key, secret) == :ok
    end

    test "returns {:error, :invalid} for invalid conn, with a valid timestamp", %{api_key: api_key, secret: secret, ref_time: ref_time} do
      timestamp = ref_time |> DateTime.to_unix() |> subtract(9) |> Integer.to_string()
      conn = get_conn(api_key, secret, timestamp)
      assert Signature.valid?(conn, "some other api key", secret) == {:error, :invalid}
    end

    test "returns {:error, :expired} for valid conn, but with an expired timestamp", %{api_key: api_key, secret: secret, ref_time: ref_time} do
      timestamp = ref_time |> DateTime.to_unix() |> subtract(20) |> Integer.to_string()
      conn = get_conn(api_key, secret, timestamp)
      assert Signature.valid?(conn, api_key, secret) == {:error, :expired}
    end

    defp get_conn(api_key, secret, timestamp) do
      nonce = "abcd"
      variables = "case-id=abcd-1234&domain=westchester&user-id=4321"
      path = "/a/small/path"
      signature = get_signature(api_key, secret, variables, timestamp, nonce, path)

      params = [
        variables: variables,
        nonce: nonce,
        signature: signature,
        timestamp: timestamp
      ]

      Phoenix.ConnTest.build_conn(:post, path, params)
    end

    defp get_signature(api_key, secret, variables, timestamp, nonce, path) do
      digest = Signature.digest(api_key, nonce, timestamp)
      hashed_variables = variables |> Signature.hash() |> Signature.encode()
      message = path <> variables <> digest <> hashed_variables
      secret = secret |> Signature.hash() |> Signature.encode16()
      message |> Signature.sign(secret) |> Signature.encode()
    end

    defp subtract(left, right), do: left - right
  end

  describe "expired?/2" do
    setup context do
      ttl = context[:ttl] || 10
      now = DateTime.utc_now()
      now_ts = DateTime.to_unix(now)
      timestamp = now_ts - ttl

      [now: now, now_ts: now_ts, timestamp: timestamp]
    end

    @tag ttl: 9
    test "returns false if timestamp is younger than TTL", %{now: now, timestamp: timestamp, ttl: ttl} do
      refute Signature.expired?(Integer.to_string(timestamp), now, ttl)
      refute Signature.expired?(timestamp, now, ttl)
    end

    @tag ttl: 10
    test "returns false if timestamp is as old as it can get", %{now: now, timestamp: timestamp, ttl: ttl} do
      refute Signature.expired?(Integer.to_string(timestamp), now, ttl)
      refute Signature.expired?(timestamp, now, ttl)
    end

    @tag ttl: 10
    test "returns true if timestamp is older than TTL", %{now: now, timestamp: timestamp, ttl: ttl} do
      timestamp = timestamp - 1

      assert Signature.expired?(Integer.to_string(timestamp), now, ttl)
      assert Signature.expired?(timestamp, now, ttl)
    end

    test "returns true if timestamp is negative", %{now: now} do
      assert Signature.expired?("-100", now)
      assert Signature.expired?(-100, now)
    end
  end

  describe "valid_signature?/3" do
    setup do
      secret = "fake_secret"
      message = "good message"
      signature = :crypto.mac(:hmac, :sha512, secret |> Signature.hash() |> Signature.encode16(), message) |> Base.encode64()
      %{signature: signature, message: message, secret: secret}
    end

    test "returns true with correct signature, message, and secret", %{signature: signature, message: message, secret: secret} do
      assert Signature.valid_signature?(signature, message, secret)
    end

    test "returns false with bad signature", %{message: message, secret: secret} do
      refute Signature.valid_signature?("bad", message, secret)
    end

    test "returns false with bad message", %{signature: signature, secret: secret} do
      refute Signature.valid_signature?(signature, "bad", secret)
    end

    test "returns false with bad secret", %{signature: signature, message: message} do
      refute Signature.valid_signature?(signature, message, "bad")
    end
  end

  describe "get_message/5" do
    test "returns the correct message" do
      path = "epi-locator.com/verify"
      nonce = "fake_nonce"
      api_key = "fake_api_key"
      timestamp = DateTime.utc_now() |> DateTime.to_unix() |> Integer.to_string()
      digest = Signature.digest(api_key, nonce, timestamp)
      variables = "case-id=1234-asdf&domain=westchester&user-id=123123"
      hashed_variables = variables |> Signature.hash() |> Base.encode64()

      expected_message = path <> variables <> digest <> hashed_variables
      actual_message = Signature.get_message(%{"path" => path, "variables" => variables, "nonce" => nonce, "timestamp" => timestamp}, api_key)
      assert actual_message == expected_message
    end
  end

  describe "digest/3" do
    test "returns the correct digest" do
      nonce = "fake_nonce"
      api_key = "fake_api_key"
      timestamp = DateTime.utc_now() |> DateTime.to_unix() |> Integer.to_string()

      expected_digest = :crypto.hash(:sha512, api_key <> nonce <> timestamp) |> Base.encode16(case: :lower)
      actual_digest = Signature.digest(api_key, nonce, timestamp)
      assert actual_digest == expected_digest
    end
  end

  describe "get_conn_info/1" do
    test "gets relevant info from conn" do
      nonce = "abcd"
      path = "/a/small/path"
      signature = "123abc"
      timestamp = "123456"
      variables = "case-id=abcd-1234&domain=westchester&user-id=4321"

      params = [
        variables: variables,
        nonce: nonce,
        signature: signature,
        timestamp: timestamp
      ]

      :post
      |> Phoenix.ConnTest.build_conn(path, params)
      |> Signature.get_conn_info()
      |> assert_eq(%{
        "variables" => variables,
        "nonce" => nonce,
        "path" => path,
        "signature" => signature,
        "timestamp" => timestamp
      })
    end
  end
end
