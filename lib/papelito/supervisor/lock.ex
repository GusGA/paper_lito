defmodule Papelito.Supervisor.Lock do
  use DynamicSupervisor
  require Logger

  def start_link(_args) do
    Logger.info("Starting #{__MODULE__} supervisor")
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_lock({team_id, server_type, game_name}) do
    server = server_type(server_type)

    child_spec = %{
      id: server,
      start: {server, :start_link, [team_id, game_name]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def server_type(:team_lock) do
    Papelito.Server.Lock.Team
  end

  def server_type(:game_lock) do
    Papelito.Server.Lock.Game
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

  def delete_lock(lock_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, lock_pid)
  end

  def locks do
    DynamicSupervisor.which_children(__MODULE__)
  end

  def count_lock do
    DynamicSupervisor.count_children(__MODULE__)
  end
end
