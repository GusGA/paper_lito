defmodule Papelito.Events.Player.Handler do
  use GenEvent

  def register_with_manager do
    Papelito.Events.Player.Manager.register(__MODULE__, nil)
  end

  def handle_event({:update, {team_name, player_name, status}}, _) do
    # TODO
    # que el status venga por parametro
    PapelitoWeb.PlayersStatusChannel.broadcast_update_status(team_name, player_name, status)
    {:ok, nil}
  end
end
