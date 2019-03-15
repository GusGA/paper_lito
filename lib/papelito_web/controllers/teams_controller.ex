defmodule PapelitoWeb.TeamsController do
  use PapelitoWeb, :controller

  def show(conn, %{"game_id" => game_name, "team_id" => team_id}) do
    case Papelito.GameManager.alive?(game_name) do
      false ->
        conn
        |> redirect(to: "/games/new")
        |> halt()

      true ->
        summary = Papelito.GameManager.summary(game_name)
        team = summary.game.teams[team_id]

        conn
        |> render("show.html", game_name: game_name, team: team, papers: [])
    end
  end

  def show_player(conn, %{"game_id" => game_name, "team_id" => team_id, "player" => player}) do
    case Papelito.GameManager.alive?(game_name) do
      false ->
        conn
        |> redirect(to: "/games/new")
        |> halt()

      true ->
        summary = Papelito.GameManager.summary(game_name)
        team = summary.game.teams[team_id]

        conn
        |> render("show.html", game_name: game_name, team: team, papers: [])
    end
  end
end
