defmodule EpiLocatorWeb.Router do
  use EpiLocatorWeb, :router
  use Plug.ErrorHandler

  import Phoenix.LiveDashboard.Router
  import EpiLocatorWeb.{UserAuth, AdminAuth}

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {EpiLocatorWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
    plug(:fetch_current_admin)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :private_web do
    plug(:require_authenticated_admin)
  end

  # This doesn't actually work: sobelow_skip ["Config.CSRF"]
  pipeline :require_valid_signature do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(EpiLocatorWeb.Plugs.RequireValidSignature)
    plug(:put_secure_browser_headers)
  end

  pipeline :put_request_id_on_session do
    plug(EpiLocatorWeb.Plugs.PutRequestIdOnSession)
  end

  scope "/", EpiLocatorWeb do
    pipe_through(:browser)

    get("/healthcheck", HealthCheckController, :index)
    get("/", PageController, :index)
  end

  scope "/metrics", EpiLocatorWeb do
    pipe_through([:browser, :private_web])

    get("/:year/:month/all", MetricsController, :all)
    get("/:year/:month/summaries", MetricsController, :summaries)
    get("/:year/:month/refinements/all", MetricsController, :refinement_all)
    get("/:year/:month/refinements/summaries", MetricsController, :refinement_summaries)
    get("/", MetricsController, :index)
  end

  scope "/", EpiLocatorWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live("/access-denied", SearchLive, :access_denied)
  end

  scope "/", EpiLocatorWeb do
    pipe_through([:browser, :require_authenticated_user, :put_request_id_on_session])

    live("/search", SearchLive, :search)
  end

  scope "/verify", EpiLocatorWeb do
    pipe_through([:require_valid_signature])

    # You will never see this below resource, but if it's not here,
    # the route won't exist for the router to match against.
    post("/", SignatureController, :index)
  end

  scope "/private" do
    pipe_through([:browser, :private_web])

    live_dashboard("/dashboard", metrics: EpiLocatorWeb.Telemetry)
    forward("/feature-flags", FunWithFlags.UI.Router, namespace: "private/feature-flags")
  end

  scope "/", EpiLocatorWeb do
    pipe_through([:browser, :redirect_if_admin_is_authenticated])

    get("/admins/log_in", AdminSessionController, :new)
    post("/admins/log_in", AdminSessionController, :create)
  end

  scope "/", EpiLocatorWeb do
    pipe_through([:browser])
    delete("/admins/log_out", AdminSessionController, :delete)
  end

  if Mix.env() == :dev do
    scope "/", EpiLocatorWeb do
      pipe_through(:browser)
      get("/commcare-signature", PageController, :commcare_signature)
    end
  end
end
