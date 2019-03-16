defmodule PapelitoWeb.PlayersStatusChannel do
  use PapelitoWeb, :channel

  def join("players_status:" <> team_id, payload, socket) do
    {:ok, "Joined player status from team #{team_id}", socket}
  end

  def broadcast_update_status(team_id, player_name, status) do
    payload = %{"player" => player_name, "status" => status}
    PapelitoWeb.Endpoint.broadcast("players_status:#{team_id}", "update_status", payload)
  end

  def handle_out(event, payload, socket) do
    push(socket, event, payload)
    {:noreply, socket}
  end
end
