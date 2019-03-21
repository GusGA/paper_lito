defmodule Papelito.Events.Player.Handler do
  use GenEvent
  alias Papelito.Server.Status.Team, as: StatusServer

  def register_with_manager do
    Papelito.Events.Player.Manager.register(__MODULE__, nil)
  end

  def handle_event({:update_player_status, {team_name, player_name, status}}, _) do
    StatusServer.update_player(team_name, player_name, status)
    {:ok, nil}
  end

  def handle_event({:update_team_status, {team_name, status}}, _) do
    StatusServer.update_team(team_name, status)
    {:ok, nil}
  end
end
