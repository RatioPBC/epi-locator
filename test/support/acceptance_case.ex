defmodule EpiLocatorWeb.AcceptanceCase do
  @moduledoc """
  A case template for running acceptance tests. Pulls in wallaby helpers.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL
      use Wallaby.Feature

      import Wallaby.Query, only: [css: 1, css: 2, button: 1]
      alias Wallaby.Element
      import EpiLocatorWeb.AcceptanceTestHelpers

      @endpoint EpiLocatorWeb.Endpoint
      alias EpiLocatorWeb.Endpoint
      @moduletag :acceptance
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EpiLocator.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EpiLocator.Repo, {:shared, self()})
    end

    session_metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(EpiLocator.Repo, self())

    {:ok, _} = Application.ensure_all_started(:wallaby)

    {:ok, session} =
      Wallaby.start_session(
        metadata: session_metadata,
        window_size: [
          width: 800,
          height: 600
        ]
      )

    {:ok, wallaby: session}
  end
end
