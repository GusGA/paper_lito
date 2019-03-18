defmodule Papelito.Event.Player.Manager do
  @name :player_update_manager

  def child_spec, do: Supervisor.Spec.worker(:gen_event, [[name: @name]])

  def update({team_name, player_name}) do
    :gen_event.notify(@name, {:update, {team_name, player_name}})
  end

  def register(handler, args), do: :gen_event.add_handler(@name, handler, args)
end
