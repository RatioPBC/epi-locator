defmodule EpiLocator.ThomsonReuters.Config do
  @moduledoc """
  Helpers for multi-environment config.
  """

  def init do
    "RELEASE_LEVEL"
    |> System.fetch_env!()
    |> settings()
    |> put_into_env()
  end

  defp put_into_env(settings) do
    Application.put_env(:epi_locator, EpiLocator.TRClient, settings)
  end

  defp settings("test") do
    [
      basic_auth: "faked-base64-encoded-basic-auth",
      cert_password: "password",
      endpoint: "s2s.beta.thomsonreuters.com",
      http_client: EpiLocator.HTTPoisonMock,
      private_key: file_or_value("test/fixtures/thomson-reuters/private.key"),
      public_cert: file_or_value("test/fixtures/thomson-reuters/public.crt")
    ]
  end

  defp settings(_) do
    [
      basic_auth: System.fetch_env!("THOMSON_REUTERS_BASIC_AUTH"),
      cert_password: System.fetch_env!("THOMSON_REUTERS_CERT_PASSWORD"),
      endpoint: System.fetch_env!("THOMSON_REUTERS_API_ENDPOINT"),
      http_client: HTTPoison,
      private_key: System.fetch_env!("THOMSON_REUTERS_PRIVATE_KEY") |> file_or_value(),
      public_cert: System.fetch_env!("THOMSON_REUTERS_PUBLIC_CERT") |> file_or_value()
    ]
  end

  defp file_or_value(value) do
    case File.read(value) do
      {:ok, contents} ->
        contents

      {:error, _} ->
        Base.decode64!(value)
    end
  end
end
