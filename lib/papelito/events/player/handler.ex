defmodule Papelito.Events.Player.Handler do
  use GenEvent
  alias Papelito.Server.Status.Team, as: StatusServer

  def register_with_manager do
    Papelito.Events.Player.Manager.register(__MODULE__, nil)
  end

  def handle_event({:update_player_status, {team_name, player_name, status}}, _) do
    StatusServer.update_player(team_name, player_name, status)

    PapelitoWeb.PlayersStatusChannel.broadcast_update_status(
      team_name,
      player_name,
      status
    )

    {:ok, nil}
  end

  def handle_event({:update_team_status, {team_name, status}}, _) do
    StatusServer.update_team(team_name, status)
    {:ok, nil}
  end
end

# team_status = Papelito.Server.Status.Team.full_status(team_name)

# case Enum.all?(team_status.players, fn {_k, v} -> v == "done" end) do
#   true ->
#     Papelito.Server.Status.Team.update_team(team_id, "done")
#     PapelitoWeb.TeamStatusChannel.broadcast_update_status(team_id, game_name, "done")

#   _ ->
#     nil
# end
