defmodule Papelito.Events.Team.Manager do
  alias Papelito.Server.Status.Team, as: StatusServer
  alias Papelito.Server.Lock.Team, as: LockServer

  def update_player_status({team_name, player_name, status}) do
    StatusServer.update_player(team_name, player_name, status)

    PapelitoWeb.PlayersStatusChannel.broadcast_update_status(
      team_name,
      player_name,
      status
    )
  end

  def update_team_status({team_name, status}) do
    StatusServer.update_team(team_name, status)
  end

  def broadcast_team_status({team_name, game_name, status}) do
    PapelitoWeb.TeamStatusChannel.broadcast_update_status(team_name, game_name, status)
  end
end
