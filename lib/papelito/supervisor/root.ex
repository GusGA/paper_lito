defmodule Papelito.Supervisor.Root do
  use Supervisor
  require Logger

  def start_link(:ok) do
    Logger.info("Starting #{__MODULE__} supervisor")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Supervisor.child_spec(
        {DynamicSupervisor, name: Papelito.Supervisor.GameSupervisor, strategy: :one_for_one},
        id: :sup_game
      ),
      Supervisor.child_spec(
        {DynamicSupervisor, name: Papelito.Supervisor.Lock, strategy: :one_for_one},
        id: :sup_lock
      ),
      Supervisor.child_spec(
        {Registry, keys: :unique, name: :game_registry},
        id: :game_registry_id
      )
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
