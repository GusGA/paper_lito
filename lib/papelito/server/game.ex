defmodule Papelito.Server.Game do
  use GenServer
  require Logger

  alias Papelito.{GamePlay, GameStorage}

  @timeout :timer.hours(1)

  def start_link(game_name, papers_per_player) do
    name = via_tuple(game_name)
    GenServer.start_link(__MODULE__, [game_name, papers_per_player], name: name)
  end

  defp via_tuple(game_name) do
    {:via, Registry, {:game_registry, game_name}}
  end

  def init([game_name, papers_per_player]) do
    state = GameStorage.fetch_game(game_name)
    state = Map.put(state, :papers_per_player, papers_per_player)
    state = Map.put(state, :game_name, game_name)
    Logger.info("Spawned game process named #{game_name}")
    {:ok, state, @timeout}
  end

  ## ------------------##
  ##    Client API     ##
  ## ------------------##

  def pid(game_name) do
    via_tuple(game_name)
    |> GenServer.whereis()
  end

  def start(game_name) do
    GenServer.call(via_tuple(game_name), :start)
  end

  def terminate(game_name) do
    GenServer.call(via_tuple(game_name), :shutdown)
  end

  def summary(game_name) do
    GenServer.call(via_tuple(game_name), :summary)
  end

  def papers_per_player(game_name) do
    GenServer.call(via_tuple(game_name), :papers_per_player)
  end

  def next_team(game_name) do
    GenServer.call(via_tuple(game_name), :next_team)
  end

  def add_team(game_name, team_name) do
    GenServer.cast(via_tuple(game_name), {:add_team, team_name})
  end

  def add_player(game_name, team_name, player) do
    GenServer.cast(via_tuple(game_name), {:add_player, team_name, player})
  end

  def add_paper(game_name, paper) do
    GenServer.call(via_tuple(game_name), {:add_paper, paper})
  end

  def mark_papers_added(game_name, team_name) do
    GenServer.call(via_tuple(game_name), {:mark_papers_added, team_name})
  end

  def fetch_paper(game_name) do
    GenServer.call(via_tuple(game_name), :fetch_paper)
  end

  def pass_paper(game_name) do
    GenServer.call(via_tuple(game_name), :pass_paper)
  end

  def start_round(game_name) do
    GenServer.call(via_tuple(game_name), :next_round)
  end

  def next_round(game_name) do
    GenServer.call(via_tuple(game_name), :next_round)
  end

  def add_point(game_name, team_name) do
    GenServer.cast(via_tuple(game_name), {:add_point, team_name})
  end

  ## ------------------##
  ##    Server API    ##
  ## ------------------##

  def handle_call(:start, _from, state) do
    new_state = GamePlay.start(state)
    GameStorage.save_game(game_name_from_registry(), new_state)
    update_team_status(new_state)
    update_scoreboard(state.game_name)
    {:reply, :ok, new_state, @timeout}
  end

  def handle_call(:summary, _from, state) do
    summary = GamePlay.summary(state)
    {:reply, summary, state, @timeout}
  end

  def handle_call(:papers_per_player, _from, state) do
    papers_per_player = GamePlay.papers_per_player(state)
    {:reply, papers_per_player, state, @timeout}
  end

  def handle_call(:next_team, _from, state) do
    {current_team, new_state} = GamePlay.next_team(state)
    GameStorage.save_game(game_name_from_registry(), new_state)
    update_team_status(new_state)
    update_scoreboard(state.game_name)
    {:reply, current_team, new_state, @timeout}
  end

  def handle_call(:next_round, _from, state) do
    {next_round, new_state} = GamePlay.next_round(state)
    GameStorage.save_game(game_name_from_registry(), new_state)
    update_scoreboard(state.game_name)
    {:reply, next_round, new_state, @timeout}
  end

  def handle_call({:add_paper, paper}, _from, state) do
    new_state = GamePlay.add_paper(state, paper)
    GameStorage.save_game(game_name_from_registry(), new_state)
    {:reply, paper, new_state, @timeout}
  end

  def handle_call({:mark_papers_added, team_name}, _from, state) do
    new_state = GamePlay.mark_papers_added(state, team_name)
    GameStorage.save_game(game_name_from_registry(), new_state)
    summary = GamePlay.summary(state)
    {:reply, summary, new_state, @timeout}
  end

  def handle_call(:fetch_paper, _from, state) do
    new_state = GamePlay.fetch_paper(state)
    GameStorage.save_game(game_name_from_registry(), new_state)
    {:reply, new_state.current_paper, new_state, @timeout}
  end

  def handle_call(:pass_paper, _from, state) do
    new_state = GamePlay.pass_paper(state)
    GameStorage.save_game(game_name_from_registry(), new_state)
    {:reply, new_state.current_paper, new_state, @timeout}
  end

  def handle_call(:shutdown, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_cast({:add_team, team_name}, state) do
    new_state = GamePlay.add_team(state, team_name)
    GameStorage.save_game(game_name_from_registry(), new_state)
    {:noreply, new_state, @timeout}
  end

  def handle_cast({:add_player, team_name, player}, state) do
    new_state = GamePlay.add_player(state, team_name, player)
    GameStorage.save_game(game_name_from_registry(), new_state)
    {:noreply, new_state, @timeout}
  end

  def handle_cast({:add_point, team_name}, state) do
    new_state = GamePlay.add_point(state, team_name)
    GameStorage.save_game(game_name_from_registry(), new_state)
    update_scoreboard(state.game_name)
    {:noreply, new_state, @timeout}
  end

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  def terminate(:normal, _state) do
    game_name_from_registry() |> GameStorage.delete_game()
    :ok
  end

  def terminate({:shutdown, :timeout}, _state) do
    game_name_from_registry() |> GameStorage.delete_game()
    :ok
  end

  def terminate(_reason, _state) do
    game_name_from_registry() |> GameStorage.delete_game()
    :ok
  end

  defp game_name_from_registry() do
    Registry.keys(:game_registry, self()) |> List.first()
  end

  defp update_scoreboard(game_name) do
    Papelito.Events.Team.Manager.notify_game_play_changes(game_name, :update_scoreboard)
  end

  defp update_team_status(new_state) do
    Enum.each(new_state.teams_order, fn team ->
      unless team != new_state.current_team do
        Papelito.Events.Team.Manager.update_team_status({team, "waiting"})
      end
    end)

    Papelito.Events.Team.Manager.update_team_status({new_state.current_team, "playing"})
  end
end
