defmodule EpiLocatorWeb.Plugs.RequireValidSignature do
  @moduledoc """
  Plugs that runs the signature validation and redirects
  to the destination.
  """

  import Plug.Conn
  alias EpiLocator.Signature
  alias EpiLocatorWeb.UserAuth

  def init(default), do: default

  def call(conn, _opts) do
    with :unused <- check_signature_cache(conn),
         :valid <- validate_signature(conn) do
      do_call(conn)
    else
      status -> do_call(status, conn)
    end
  end

  defp check_signature_cache(conn) do
    conn
    |> get_signature()
    |> Signature.Cache.exists?()
    |> case do
      {:ok, true} -> :used
      {:ok, false} -> :unused
    end
  end

  defp validate_signature(conn) do
    case signer().valid?(conn, commcare_signature_key(), commcare_signature_secret()) do
      :ok -> :valid
      _ -> :invalid
    end
  end

  defp do_call(conn) do
    path = get_path(conn)
    query_string = get_query_string(conn)
    signature = get_signature(conn)
    user_id = get_user_id(conn)
    return_to = "#{path}?#{query_string}"
    Signature.Cache.put(signature, signature)

    conn
    |> put_session(:user_return_to, return_to)
    |> UserAuth.log_in_user(user_id)
  end

  defp do_call(:invalid, conn) do
    conn
    |> send_resp(403, "Invalid signature")
    |> halt()
  end

  defp do_call(:used, conn) do
    conn
    |> send_resp(403, "Signature already used")
    |> halt()
  end

  def get_user_id(conn) do
    get_query_string_value(conn, "user-id")
  end

  def get_query_string(conn) do
    %{"variables" => variables} = Signature.get_conn_info(conn)
    variables
  end

  def get_path(conn) do
    path = get_query_string_value(conn, "path")

    if String.starts_with?(path, "/") do
      path
    else
      "/#{path}"
    end
  end

  def get_signature(conn) do
    %{"signature" => signature} = Signature.get_conn_info(conn)
    signature
  end

  defp signer, do: EpiLocator.signer()

  defp get_query_string_value(conn, key) do
    conn
    |> get_query_string()
    |> URI.decode_query()
    |> Map.get(key)
  end

  def commcare_signature_key, do: Application.get_env(:epi_locator, :commcare_signature_key)
  def commcare_signature_secret, do: Application.get_env(:epi_locator, :commcare_signature_secret)
end
