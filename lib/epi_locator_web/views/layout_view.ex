defmodule EpiLocatorWeb.LayoutView do
  use EpiLocatorWeb, :view

  @default_destination "https://preventepidemics.org/covid19/us-response/digital-products/epi-locator/"

  @spec favicon_href(Plug.Conn.t()) :: String.t()
  def favicon_href(%Plug.Conn{} = conn) do
    icon = System.get_env("APP_FAVICON_URL", Routes.static_path(conn, "/images/favicon.ico"))
    to_string(icon)
  end

  @spec header_logo_link(Plug.Conn.t()) :: {:safe, [binary]}
  def header_logo_link(%Plug.Conn{} = conn) do
    destination = System.get_env("APP_LOGO_LINK_URL", @default_destination)
    logo_url = System.get_env("APP_LOGO_URL", Routes.static_path(conn, "/images/logo-header.svg"))

    link to: destination do
      img_tag(logo_url)
    end
  end

  @spec title_tag(Plug.Conn.t()) :: {:safe, [binary]}
  def title_tag(%Plug.Conn{assigns: assigns}) do
    live_title_tag(assigns[:page_title] || app_name())
  end
end
