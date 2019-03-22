defmodule PapelitoWeb.PlayerController do
  use PapelitoWeb, :controller

  def show(conn, %{"game_id" => game_name, "team_id" => team_id, "player_name" => name}) do
    case Papelito.GameManager.alive?(game_name) do
      false ->
        conn
        |> put_flash(:error, "The game does not exist, please create a new one")
        |> redirect(to: "/games/new")
        |> halt()

      true ->
        summary = Papelito.GameManager.summary(game_name)
        max_papers = Papelito.GameManager.papers_per_player(game_name)
        team = summary.game.teams[team_id]

        conn
        |> render(
          "show.html",
          game_name: game_name,
          team: team,
          papers: [],
          max_papers: max_papers
        )
    end
  end
end
