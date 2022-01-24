defmodule EpiLocator.Signature do
  @moduledoc """
  Security signature validation.
  """

  @time_mod Application.compile_env!(:epi_locator, :time)
  defp time_mod(), do: @time_mod

  @callback valid?(Plug.Conn.t(), String.t(), String.t()) :: :ok | {:error, :expired | :invalid}
  def valid?(%Plug.Conn{} = conn, api_key, secret) do
    %{"signature" => signature, "timestamp" => timestamp} = c = get_conn_info(conn)

    if expired?(timestamp) do
      {:error, :expired}
    else
      message = get_message(c, api_key)

      if valid_signature?(signature, message, secret) do
        :ok
      else
        {:error, :invalid}
      end
    end
  end

  @spec valid_signature?(signature :: binary(), message :: binary(), secret :: binary()) :: boolean()
  def valid_signature?(signature, message, secret) do
    secret = secret |> hash() |> encode16()

    message
    |> sign(secret)
    |> encode()
    |> Euclid.String.secure_compare(signature)
  end

  @ttl Application.compile_env!(:epi_locator, EpiLocator)[:ttl]
  def ttl(unit \\ :second)
  def ttl(:second), do: @ttl / 1000
  def ttl(:millisecond), do: @ttl

  def expired?(timestamp, now \\ time_mod().utc_now(), ttl \\ ttl(:second))

  def expired?(timestamp, now, ttl) when is_binary(timestamp) do
    timestamp
    |> String.to_integer()
    |> expired?(now, ttl)
  end

  def expired?(timestamp, _now, _ttl) when is_integer(timestamp) and timestamp <= 0 do
    true
  end

  def expired?(timestamp, now, ttl) when is_integer(timestamp) do
    now = DateTime.to_unix(now)
    timestamp < now - ttl
  end

  @signature_keys ~w(signature nonce timestamp)
  @spec get_conn_info(Plug.Conn.t()) :: map()
  def get_conn_info(%Plug.Conn{params: params, request_path: path}) do
    signed_params = Map.take(params, @signature_keys)

    params
    |> Map.drop(@signature_keys)
    |> Map.merge(signed_params)
    |> Map.put("path", path)
  end

  def get_message(%{"path" => path, "nonce" => nonce, "variables" => variables, "timestamp" => timestamp}, api_key) do
    digest = digest(api_key, nonce, timestamp)

    hashed_variables =
      variables
      |> hash()
      |> encode()

    path <> variables <> digest <> hashed_variables
  end

  def digest(api_key, nonce, timestamp) do
    [api_key, nonce, timestamp]
    |> Enum.join("")
    |> hash()
    |> encode16()
  end

  def hash(message) do
    :crypto.hash(:sha512, message)
  end

  def encode(message) do
    Base.encode64(message)
  end

  def encode16(message) do
    Base.encode16(message, case: :lower)
  end

  def nonce(n \\ 16) do
    n |> :crypto.strong_rand_bytes() |> encode()
  end

  def sign(message, secret) do
    :crypto.mac(:hmac, :sha512, secret, message)
  end
end
