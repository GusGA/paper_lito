defmodule Papelito.Events.Player.Manager do
  @name :player_update_manager

  def child_spec, do: Supervisor.Spec.worker(GenEvent, [[name: @name]])

  def update_player_status({team_name, player_name, status}) do
    GenEvent.notify(@name, {:update_player_status, {team_name, player_name, status}})
  end

  def update_team_status({team_name, status}) do
    GenEvent.notify(@name, {:update_team_status, {team_name, status}})
  end

  def register(handler, args), do: GenEvent.add_handler(@name, handler, args)
end
