defmodule Papelito.Server.Lock.Game do
  use GenServer
  require Logger

  @timeout :timer.hours(1)

  def start_link(game_name) do
    GenServer.start_link(__MODULE__, [game_name], name: via_tuple(game_name))
  end

  defp via_tuple(game_name) do
    {:via, Registry, {:team_lock_registry, game_name}}
  end

  def init([game_name]) do
    _summary = Papelito.GameManager.summary(game_name)
    Logger.info("Spawned lock process named #{game_name}")
    {:ok, build_lock(), @timeout}
  end

  ## Client functions

  def scoreboard_locked?(game_name) do
    GenServer.call(via_tuple(game_name), :scoreboard_locked?)
  end

  def bowl_locked?(game_name) do
    GenServer.call(via_tuple(game_name), :bowl_locked?)
  end

  def lock_scoreboard(game_name) do
    GenServer.cast(via_tuple(game_name), :lock_scoreboard)
  end

  def lock_bowl(game_name) do
    GenServer.cast(via_tuple(game_name), :lock_bowl)
  end

  def unlock_bowl(game_name) do
    GenServer.cast(via_tuple(game_name), :unlock_bowl)
  end

  def unlock_scoreboard(game_name) do
    GenServer.cast(via_tuple(game_name), :unlock_scoreboard)
  end

  def lock_all(game_name) do
    GenServer.cast(via_tuple(game_name), :lock_all)
  end

  def unlock_all(game_name) do
    GenServer.cast(via_tuple(game_name), :unlock_all)
  end

  ## Server functions

  def handle_call(:scoreboard_locked?, _from, state) do
    {:reply, state.scoreboard, state, @timeout}
  end

  def handle_call(:bowl_locked?, _from, state) do
    {:reply, state.bowl, state, @timeout}
  end

  def handle_cast(:lock_scoreboard, state) do
    {:noreply, update_lock(state, :scoreboard, true), @timeout}
  end

  def handle_cast(:lock_bowl, state) do
    {:noreply, update_lock(state, :bowl, true), @timeout}
  end

  def handle_cast(:unlock_scoreboard, state) do
    {:noreply, update_lock(state, :scoreboard, false), @timeout}
  end

  def handle_cast(:unlock_bowl, state) do
    {:noreply, update_lock(state, :bowl, false), @timeout}
  end

  def handle_cast(:unlock_all, state) do
    {:noreply, unlock_all_state(state), @timeout}
  end

  def handle_cast(:lock_all, state) do
    {:noreply, lock_all_state(state), @timeout}
  end

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  def terminate({:shutdown, :timeout}, _state) do
    :ok
  end

  ## Helper functions

  defp build_lock() do
    %{scoreboard: false, bowl: false}
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

  defp update_all(state, value) do
    %{state | bowl: value, scoreboard: value}
  end
end
