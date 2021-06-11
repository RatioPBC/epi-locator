defmodule EpiLocator.Accounts.UserToken do
  @moduledoc """
  Simple auth model that generates/stores session tokens.
  """

  use Ecto.Schema
  import Ecto.Query

  @hash_algorithm :sha256
  @rand_size_session_token 32
  @session_validity_in_days 1

  schema "users_tokens" do
    field(:token, :binary)
    field(:user_id, :string)

    timestamps(updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.
  """
  def build_session_token(user_id) do
    token = generate_session_token()
    {token, %EpiLocator.Accounts.UserToken{token: token, user_id: user_id}}
  end

  def generate_session_token do
    :crypto.strong_rand_bytes(@rand_size_session_token)
  end

  def verify_session_token_query(token) do
    query =
      from(token in session_token_query(token),
        where: token.inserted_at > ago(@session_validity_in_days, "day")
      )

    {:ok, query}
  end

  def session_token_query(token) do
    from(EpiLocator.Accounts.UserToken, where: [token: ^token])
  end

  def user_id_query(user_id) do
    from(EpiLocator.Accounts.UserToken, where: [user_id: ^user_id])
  end

  def encode(binary_token) do
    Base.encode16(binary_token, padding: false)
  end

  def decode(string_token) do
    Base.decode16(string_token, padding: false)
  end

  def hash_bytes(bytes) do
    :crypto.hash(@hash_algorithm, bytes)
  end
end
