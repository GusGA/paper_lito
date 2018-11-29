defmodule Papelito.Supervisor.Root do
  use Supervisor
  require Logger

  def start_link(:ok) do
    Logger.info("Starting #{__MODULE__} supervisor")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {DynamicSupervisor, name: Papelito.Supervisor.GameSupervisor, strategy: :one_for_one},
      {Registry, keys: :unique, name: :game_registry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
