defmodule EpiLocatorWeb.Test.ComponentEmbeddingLiveView do
  defmacro __using__(opts) do
    default_assigns = Keyword.get(opts, :default_assigns)

    quote do
      use EpiLocatorWeb, :live_view

      import EpiLocatorWeb.LiveComponents.Helpers

      def mount(_params, _session, socket) do
        {:ok, socket |> assign(unquote(default_assigns))}
      end

      def handle_info({:assigns, new_assigns}, socket) do
        {:noreply, socket |> assign(new_assigns)}
      end
    end
  end
end
