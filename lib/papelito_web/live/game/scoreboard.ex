defmodule PapelitoWeb.GameLive.Scoreboard do
  use Phoenix.LiveView
  alias PapelitoWeb.Router.Helpers, as: Routes
  alias Papelito.Server.Status.Team, as: StatusServer

  def mount(%{path_params: %{"game_id" => game_id}}, socket) do
    case Papelito.GameManager.alive?(game_id) do
      false ->
        {:stop,
         socket
         |> put_flash(:error, "The game does not exist, please create a new one")
         |> redirect(to: Routes.page_path(%Plug.Conn{}, :index))}

      true ->
        summary = Papelito.GameManager.summary(game_id)
        statuses = teams_status(summary.game.teams)
        {:ok, assign(socket, %{game_name: game_id, summary: summary, statuses: statuses})}
    end
  end

  def render(assigns), do: PapelitoWeb.GameView.render("scoreboard.html", assigns)

  defp teams_status(teams) do
    statues =
      Map.keys(teams)
      |> Enum.map(fn id -> Task.async(fn -> [id, StatusServer.team_status(id)] end) end)
      |> Enum.map(&Task.await/1)
      |> Enum.reduce(%{}, fn [id, status], acc -> Map.put(acc, id, status) end)
  end
end
