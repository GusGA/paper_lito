defmodule PapelitoWeb.Router do
  use PapelitoWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(Phoenix.LiveView.Flash)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:put_layout, {PapelitoWeb.LayoutView, :app})
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", PapelitoWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/rules", PageController, :rules)
    live("/games/new", GameLive.New)
    get("/games/:game_id", GameController, :show)
    # post("/games/create", GameController, :create)
    get("/games/:game_id/teams/:team_id", TeamsController, :show)
    live("/games/:game_id/teams/:team_id/:player_name", PlayerLive.Show)
    live("/games/:game_id/scoreboard", GameLive.Scoreboard)
    live("/games/:game_id/bowl", GameLive.Bowl)
    # get("/games/:game_id/bowl", GameController, :bowl)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PapelitoWeb do
  #   pipe_through :api
  # end
end
