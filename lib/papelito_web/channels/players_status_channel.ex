defmodule PapelitoWeb.PlayersStatusChannel do
  use PapelitoWeb, :channel

  def join("players_status:" <> team_id, %{"game_id" => game_id} = payload, socket) do
    team = Papelito.Server.Status.Team.full_status(team_id)
    {:ok, team, socket}
  end

  def broadcast_update_status(team_id, player_name, status) do
    payload = %{"player" => player_name, "status" => status}
    PapelitoWeb.Endpoint.broadcast("players_status:#{team_id}", "update_status", payload)
  end

  def handle_in("check_team_status", %{"game_id" => game_name, "team_id" => team_id}, socket) do
    {:noreply, socket}
  end

  def handle_out(event, payload, socket) do
    push(socket, event, payload)
    {:noreply, socket}
  end
end
