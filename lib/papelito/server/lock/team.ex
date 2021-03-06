defmodule Papelito.Server.Lock.Team do
  use GenServer
  require Logger

  @timeout :timer.hours(1)

  def start_link(team_id, game_name) do
    GenServer.start_link(__MODULE__, [team_id, game_name], name: via_tuple(team_id))
  end

  defp via_tuple(team_id) do
    {:via, Registry, {:team_lock_registry, team_id}}
  end

  def init([team_id, game_name]) do
    summary = Papelito.GameManager.summary(game_name)
    team = summary.game.teams[team_id]
    state = build_lock(team_id, team.players)
    Logger.info("Spawned lock process named #{team_id}")
    {:ok, state, @timeout}
  end

  ## Client functions

  def team_locked?(team_id) do
    GenServer.call(via_tuple(team_id), {:team_unlocked?, team_id})
  end

  def player_locked?(team_id, player_name) do
    GenServer.call(via_tuple(team_id), {:player_unlocked?, player_name})
  end

  def lock_team(team_id) do
    GenServer.cast(via_tuple(team_id), {:lock_team, team_id})
  end

  def unlock_team(team_id) do
    GenServer.cast(via_tuple(team_id), {:lock_team, team_id})
  end

  def lock_player(team_id, player_name) do
    GenServer.cast(via_tuple(team_id), {:lock_player, player_name})
  end

  def unlock_player(team_id, player_name) do
    GenServer.cast(via_tuple(team_id), {:unlock_player, player_name})
  end

  def lock_all(team_id) do
    GenServer.cast(via_tuple(team_id), :lock_all)
  end

  def unlock_all(team_id) do
    GenServer.cast(via_tuple(team_id), :unlock_all)
  end

  ## Server functions

  def handle_call({:player_unlocked?, player_name}, _from, state) do
    {:reply, get_lock(state, player_name), state, @timeout}
  end

  def handle_call({:team_unlocked?, team_name}, _from, state) do
    {:reply, get_lock(state, team_name), state, @timeout}
  end

  def handle_cast(:unlock_all, state) do
    {:noreply, unlock_all_state(state), @timeout}
  end

  def handle_cast(:lock_all, state) do
    {:noreply, lock_all_state(state), @timeout}
  end

  def handle_cast({:lock_player, player_name}, state) do
    {:noreply, update_lock(state, player_name, true), @timeout}
  end

  def handle_cast({:lock_team, team_id}, state) do
    {:noreply, update_lock(state, team_id, true), @timeout}
  end

  def handle_cast({:unlock_player, player_name}, state) do
    {:noreply, update_lock(state, player_name, false), @timeout}
  end

  def handle_cast({:unlock_team, team_id}, state) do
    {:noreply, update_lock(state, team_id, false), @timeout}
  end

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  def terminate({:shutdown, :timeout}, _state) do
    :ok
  end

  ## Helper functions

  defp build_lock(team_id, players) do
    Enum.reduce(players, %{team_id => false}, fn name, state -> Map.put(state, name, false) end)
  end

  defp unlock_all_state(state) do
    update_all(state, false)
  end

  defp lock_all_state(state) do
    update_all(state, true)
  end

  defp update_lock(state, resource_name, lock_status) do
    Map.put(state, resource_name, lock_status)
  end

  defp get_lock(state, resource_name), do: Map.get(state, resource_name)

  defp update_all(state, value) do
    Enum.reduce(state, %{}, fn {player_or_team, _v}, new_state ->
      Map.put(new_state, player_or_team, value)
    end)
  end
end
