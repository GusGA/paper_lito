defmodule PapelitoWeb.TeamStatusChannel do
  use PapelitoWeb, :channel

  require Logger

  def join("team_status:" <> game_name, _payload, socket) do
    summary = Papelito.GameManager.summary(game_name)
    payload = fetch_team_status(summary.game.teams)
    {:ok, payload, socket}
  end

  def broadcast_update_status(team_id, game_name, status) do
    IO.inspect("hola desde el broadcast_update_status del channel")
    payload = %{"team" => team_id, "status" => status}
    PapelitoWeb.Endpoint.broadcast("team_status:#{game_name}", "update_teams_status", payload)
  end

  defp fetch_team_status(teams) do
    Map.keys(teams)
    |> Enum.map(fn team_id ->
      Task.async(fn -> Papelito.Server.Status.Team.full_status(team_id) end)
    end)
    |> Enum.map(&Task.await/1)
  end
end
