defmodule PapelitoWeb.Router do
  use PapelitoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PapelitoWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/rules", PageController, :rules)

    resources("/games", GameController, only: [:new, :show])
    get("/games/:game_id/teams/:team_id", TeamsController, :show)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PapelitoWeb do
  #   pipe_through :api
  # end
end
