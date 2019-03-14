defmodule Papelito.Server.Lock.Team do
  use GenServer
  require Logger

  @timeout :timer.minutes(10)

  def start_link({team_id, game_name}) do
    GenServer.start_link(__MODULE__, {team_id, game_name}, name: via_tuple(team_id))
  end

  defp via_tuple(team_id) do
    {:via, Registry, {:team_lock_registry, team_id}}
  end

  def init({team_id, game_name}) do
    summary = Papelito.GameManager.summary(game_name)
    team = summary.game.teams[team_id]
    Logger.info("Spawned lock process named #{team_id}")
    {:ok, build_lock(team_id, team.players), @timeout}
  end

  def build_lock(team_id, players) do
    Enum.reduce(players, %{team_id => false}, fn name, state -> Map.put(state, name, false) end)
  end

  def unlock_all(state) do
    update_all(state, false)
  end

  def lock_all(state) do
    update_all(state, true)
  end

  def update_all(state, value) do
    Enum.reduce(state, %{}, fn {player, _v}, new_state -> Map.put(new_state, player, value) end)
  end
end
