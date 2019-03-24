defmodule Papelito.Server.Status.Team do
  use GenServer
  require Logger
  alias __MODULE__

  defmodule State do
    @derive Jason.Encoder
    defstruct team_status: "",
              players: %{},
              game_name: "",
              team_id: ""
  end

  alias Papelito.Model.Team

  @timeout :timer.hours(1)

  def start_link(team_id, game_name) do
    GenServer.start_link(__MODULE__, [team_id, game_name], name: via_tuple(team_id))
  end

  defp via_tuple(team_id) do
    {:via, Registry, {:team_status_registry, team_id}}
  end

  def init([team_id, game_name]) do
    summary = Papelito.GameManager.summary(game_name)
    state = build_status_state(summary.game.teams[team_id], game_name)
    Logger.info("Spawned team status process named #{team_id}")
    {:ok, state, @timeout}
  end

  ## Client Api ##

  def update_player(team_name, player_name, status) do
    GenServer.cast(via_tuple(team_name), {:update_player, {team_name, player_name, status}})
  end

  def update_team(team_name, status) do
    GenServer.cast(via_tuple(team_name), {:update_team, {team_name, status}})
  end

  def player_status(team_name, player_name) do
    GenServer.call(via_tuple(team_name), {:player_status, player_name})
  end

  def team_status(team_name) do
    GenServer.call(via_tuple(team_name), :team_status)
  end

  def full_status(team_name) do
    GenServer.call(via_tuple(team_name), :full_status)
  end

  ## Server Api ##

  def handle_call({:player_status, {player_name}}, _from, state) do
    {:reply, get_player_status(state, player_name), state, @timeout}
  end

  def handle_call(:team_status, _from, state) do
    {:reply, get_team_status(state), state, @timeout}
  end

  def handle_call(:full_status, _from, state) do
    {:reply, state, state, @timeout}
  end

  def handle_cast({:update_player, {_team_name, player_name, status}}, state) do
    new_state = update_player_status(state, player_name, status)
    send(self(), :all_players_done?)
    {:noreply, new_state, @timeout}
  end

  def handle_cast({:update_team, {_team_name, status}}, state) do
    {:noreply, update_team_status(state, status), @timeout}
  end

  def handle_info(:all_players_done?, state) do
    new_state =
      case Enum.all?(state.players, fn {_k, v} -> v == "done" end) do
        true ->
          Papelito.Events.Team.Manager.broadcast_team_status(
            {state.team_id, state.game_name, "done"}
          )

          Enum.each(state.players, fn {player_name, _status} ->
            spawn(fn ->
              Papelito.LockManager.lock_player(state.team_id, player_name)
            end)
          end)

          update_team_status(state, "done")

        _ ->
          state
      end

    {:noreply, new_state}
  end

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  def terminate({:shutdown, :timeout}, _state) do
    :ok
  end

  ## Helper functions ##

  defp build_status_state(%Team{} = team, game_name) do
    players =
      Enum.reduce(team.players, %{}, fn name, players ->
        Map.put(players, name, "pending")
      end)

    %State{team_status: "pending", players: players, game_name: game_name, team_id: team.id}
  end

  defp update_player_status(state, player_name, status) do
    players = Map.put(state.players, player_name, status)
    state = Map.put(state, :players, players)
    state
  end

  defp update_team_status(state, status) do
    Map.put(state, :team_status, status)
  end

  defp get_team_status(state) do
    Map.get(state, :team_status)
  end

  defp get_player_status(state, player_name) do
    Map.get(state.players, player_name)
  end
end
