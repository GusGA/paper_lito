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
        Papelito.Events.Team.Manager.subscribe_score_board_live_view(game_id)
        {:ok, assign(socket, %{game_name: game_id, summary: summary, statuses: statuses})}
    end
  end

  def render(assigns), do: PapelitoWeb.GameView.render("scoreboard.html", assigns)

  def handle_info(:update_scoreboard, socket) do
    game_id = socket.assigns.game_name
    summary = Papelito.GameManager.summary(game_id)
    statuses = teams_status(summary.game.teams)
    {:noreply, assign(socket, %{game_name: game_id, summary: summary, statuses: statuses})}
  end

  defp teams_status(teams) do
    Map.keys(teams)
    |> Enum.map(fn id -> Task.async(fn -> [id, StatusServer.team_status(id)] end) end)
    |> Enum.map(&Task.await/1)
    |> Enum.reduce(%{}, fn [id, status], acc -> Map.put(acc, id, status) end)
  end
end
