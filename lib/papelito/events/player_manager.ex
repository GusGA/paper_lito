defmodule Papelito.Event.PlayerManager do
  @name :player_update_manager

  def child_spec, do: Supervisor.Spec.worker(GenEvent, [[name: @name]])

  def update({team_name, player_name}) do
    GenEvent.notify(@name, {:update, {team_name, player_name}})
  end

  def register(handler, args), do: GenEvent.add_handler(@name, handler, args)
end
