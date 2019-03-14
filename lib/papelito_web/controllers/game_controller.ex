defmodule PapelitoWeb.GameController do
  use PapelitoWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html", players: [], teams: [], token: get_csrf_token(), sorted_teams: "")
  end

  def create(conn, params) do
    case validate_subject_params(params["game_subject"]) do
      true ->
        game_data = create_game(params)

        conn
        |> put_flash(:info, "Game Created successfully.")
        |> redirect(to: Routes.game_path(conn, :show, game_data.game_name))

      false ->
        render(conn, "new.html", players: [], teams: [], token: get_csrf_token(), sorted_teams: "")
    end
  end

  def show(conn, %{"id" => game_name}) do
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

  def all_saved() do
  end

  defp create_game(%{"game_subject" => subject, "sorted_teams" => sorted_teams} = _params) do
    teams = Poison.decode!(sorted_teams, %{keys: :atoms!})
    {:name, name} = Papelito.GameManager.new_game(subject)
    Papelito.GameManager.add_teams(name, teams)

    %{game_name: name, summary: Papelito.GameManager.summary(name)}
  end

  defp validate_subject_params(subject) do
    is_binary(subject) && subject !== "" && !is_nil(subject)
  end
end
