defmodule Papelito.Supervisor.GameSupervisor do
  use DynamicSupervisor
  require Logger

  def start_link(_args) do
    Logger.info("Starting #{__MODULE__} supervisor")
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_game(game_name, papers_per_player) do
    child_spec = %{
      id: Papelito.Server.Game,
      start: {Papelito.Server.Game, :start_link, [game_name, papers_per_player]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor,
      restart: :permanent,
      shutdown: 20000
    }
  end

  def end_game(game_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, game_pid)
  end

  def games do
    DynamicSupervisor.which_children(__MODULE__)
  end

  def count_games do
    DynamicSupervisor.count_children(__MODULE__)
  end
end
