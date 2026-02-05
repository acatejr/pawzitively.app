defmodule PawzitivelyWeb.Router do
  use PawzitivelyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PawzitivelyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PawzitivelyWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/owners", OwnerLive.Index, :index
    live "/owners/new", OwnerLive.Form, :new
    live "/owners/:id", OwnerLive.Show, :show
    live "/owners/:id/edit", OwnerLive.Form, :edit

    live "/pets", PetLive.Index, :index
    live "/pets/new", PetLive.Form, :new
    live "/pets/:id", PetLive.Show, :show
    live "/pets/:id/edit", PetLive.Form, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", PawzitivelyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:pawzitively, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PawzitivelyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
