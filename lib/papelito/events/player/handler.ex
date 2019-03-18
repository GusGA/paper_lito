defmodule Papelito.Events.Player.Handler do
  use GenEvent

  def register_with_manager do
    Papelito.Event.Player.Manager.register(__MODULE__, nil)
  end

  def handle_event({:update, {team_name, player_name}}, _) do
    # TODO
    # que el status venga por parametro
    PapelitoWeb.PlayersStatusChannel.broadcast_update_status(team_name, player_name, "done")
    {:ok, nil}
  end
end
