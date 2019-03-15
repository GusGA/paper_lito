defmodule PapelitoWeb.GameController do
  use PapelitoWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, params) do
    game_data = create_game(params)

    conn
    |> put_flash(:info, "Game Created successfully.")
    |> redirect(to: Routes.game_path(conn, :show, game_data.game_name))
  end

  def show(conn, %{"game_id" => game_name}) do
    case Papelito.GameManager.alive?(game_name) do
      false ->
        conn
        |> put_flash(:error, "The game does not exist, please create a new one")
        |> redirect(to: "/games/new")
        |> halt()

      true ->
        game_summary = Papelito.GameManager.summary(game_name)

        conn
        |> render("show.html", game_name: game_name, summary: game_summary)
    end
  end

  ## -------------- ##
  ##    Helpers     ##
  ## -------------- ##

  defp create_game(%{"sorted_teams" => sorted_teams} = _params) do
    teams = Poison.decode!(sorted_teams, %{keys: :atoms!})
    {:name, name} = Papelito.GameManager.new_game()
    Papelito.GameManager.add_teams(name, teams)

    %{game_name: name, summary: Papelito.GameManager.summary(name)}
  end
end
