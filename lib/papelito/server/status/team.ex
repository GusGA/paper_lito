defmodule Papelito.Server.Status.Team do
  use GenServer
  require Logger

  @timeout :timer.hours(1)

  def start_link(team_name) do
    name = via_tuple(team_name)
    GenServer.start_link(__MODULE__, team_name, name: name)
  end

  defp via_tuple(team_name) do
    {:via, Registry, {:team_status_registry, team_name}}
  end

  def init(team_name) do
    Logger.info("Spawned team status process named #{team_name}")
    {:ok, %{}, @timeout}
  end

  ## Client Api ##

  def update_player(team_name, player_name, status) do
    # cast
  end

  def update_team(team_name, status) do
    # cast
  end

  def player_status(team_name, player_name) do
    # call
  end

  def team_status(team_name) do
    # call
  end

  ## Server Api ##

  ## Helper functions ##
end
