defmodule PapelitoWeb.GameController do
  use PapelitoWeb, :controller
  use Drab.Controller, commander: PapelitoWeb.GameCommander

  def new(conn, _params) do
    render(conn, "new.html", players: [])
  end

  def show(conn, %{"id" => game_name}) do
    case Papelito.GameManager.alive?(game_name) do
      false ->
        conn
        # |> put_flash(:error, "The game does not exist, please create a new one")
        |> redirect(to: "/games/new")
        |> halt()

      true ->
        game_summary = Papelito.GameManager.summary(game_name)

        conn
        |> render("show.html", game_name: game_name, game_summary: encode(game_summary))
    end
  end

  defp encode(game_summary) do
    Poison.encode!(%{
      subject: game_summary.game.subject,
      teams: Enum.map(game_summary.game.teams, fn {_k, v} -> Map.from_struct(v) end)
    })
  end

  ## -------------- ##
  ##    Helpers     ##
  ## -------------- ##

  def all_saved() do
  end

  defp create_game(%{"subject" => subject, "teams" => teams} = _params) do
    {:name, name} = Papelito.GameManager.new_game(subject)
    Papelito.GameManager.add_teams(name, teams)
    %{name: name}
  end

  defp validate_subject_params(subject) do
    is_binary(subject) && subject !== "" && !is_nil(subject)
  end
end
