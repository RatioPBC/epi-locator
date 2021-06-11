defmodule EpiLocatorWeb.LayoutViewTest do
  use EpiLocatorWeb.ConnCase, async: true

  import Phoenix.HTML
  import EpiLocatorWeb.Gettext

  alias EpiLocatorWeb.LayoutView, as: View

  def env_from_context(context, key) do
    new_value = context[key]

    if new_value do
      env_var = key |> Atom.to_string() |> String.upcase()
      previous_value = System.get_env(env_var)
      System.put_env(env_var, new_value)

      on_exit(fn ->
        if previous_value do
          System.put_env(env_var, previous_value)
        else
          System.delete_env(env_var)
        end
      end)
    end

    context
  end

  describe "favicon_href/1" do
    setup context do
      env_from_context(context, :app_favicon_url)
    end

    @tag app_favicon_url: Euclid.Extra.Random.string()
    test "returns tag with configured app favicon", %{app_favicon_url: app_favicon_url, conn: conn} do
      assert conn
             |> get("/")
             |> View.favicon_href() == app_favicon_url
    end

    test "returns tag with default favicon", %{conn: conn} do
      assert conn
             |> get("/")
             |> View.favicon_href() == "/images/favicon.ico"
    end
  end

  describe "header_logo_link/1" do
    setup context do
      context
      |> env_from_context(:app_logo_url)
      |> env_from_context(:app_logo_link_url)
    end

    @tag app_logo_url: Euclid.Extra.Random.string()
    @tag app_logo_link_url: Euclid.Extra.Random.string()
    test "returns tag with configured logo URL and destination", %{app_logo_link_url: destination, app_logo_url: url, conn: conn} do
      html = conn |> View.header_logo_link() |> safe_to_string()
      assert html =~ destination
      assert html =~ url
    end

    test "returns tag with default logo URL and destination", %{conn: conn} do
      html =
        conn
        |> get("/")
        |> View.header_logo_link()
        |> safe_to_string()

      default_destination = "https://preventepidemics.org/covid19/us-response/digital-products/epi-locator/"
      default_logo = "logo-header.svg"

      assert html =~ default_destination
      assert html =~ default_logo
    end
  end

  describe "title_tag_value/1" do
    setup context do
      env_from_context(context, :app_name)
    end

    test "returns tag with assigned page title" do
      page_title = Euclid.Extra.Random.string()
      assert %Plug.Conn{assigns: %{page_title: page_title}} |> View.title_tag() |> safe_to_string() =~ page_title
    end

    @tag app_name: Euclid.Extra.Random.string()
    test "returns tag with configured app name", %{app_name: app_name} do
      assert %Plug.Conn{assigns: %{}} |> View.title_tag() |> safe_to_string() =~ app_name
    end

    test "returns tag with default page title" do
      page_title = gettext("app name")
      assert %Plug.Conn{assigns: %{}} |> View.title_tag() |> safe_to_string() =~ page_title
    end
  end
end
