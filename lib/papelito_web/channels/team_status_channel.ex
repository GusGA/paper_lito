defmodule PapelitoWeb.TeamStatusChannel do
  use PapelitoWeb, :channel

  def join("team_status:" <> game_name, payload, socket) do
    summary = Papelito.GameManager.summary(game_name)
    payload = fetch_team_status(summary.game.teams)
    {:ok, payload, socket}
  end

  defp fetch_team_status(teams) do
    Enum.map(teams, fn team ->
      Task.async(fn -> Papelito.Server.Status.Team.full_status(team.id) end)
    end)
    |> Enum.map(&Task.await/1)
  end
end
