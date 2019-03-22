defmodule PapelitoWeb.GameController do
  use PapelitoWeb, :controller

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

  def bowl(conn, %{"game_id" => game_name}) do
    case Papelito.GameManager.alive?(game_name) do
      false ->
        conn
        |> put_flash(:error, "The game does not exist, please create a new one")
        |> redirect(to: "/games/new")
        |> halt()

      true ->
        game_summary = Papelito.GameManager.summary(game_name)

        conn
        |> render("bowl.html", game_name: game_name, summary: game_summary)
    end
  end
end
