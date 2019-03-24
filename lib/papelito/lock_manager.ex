defmodule Papelito.LockManager do
  alias Papelito.Server.Lock.Game, as: GameLock
  alias Papelito.Server.Lock.Team, as: TeamLock
  alias Papelito.Supervisor.Lock, as: LockSupervisor

  def start_team_lock(team_id, game_id) do
    LockSupervisor.start_lock({team_id, :team_lock, game_id})
  end

  def player_locked?(team_id, player_name) do
    TeamLock.player_locked?(team_id, player_name)
  end

  def lock_player(team_id, player_name) do
    TeamLock.lock_player(team_id, player_name)
  end

  def lock_bowl(game_id) do
    GameLock.lock_bowl(game_id)
  end

  def lock_scoreboard(game_id) do
    GameLock.lock_scoreboard(game_id)
  end

  def unlock_bowl(game_id) do
    GameLock.unlock_bowl(game_id)
  end

  def unlock_scoreboard(game_id) do
    GameLock.unlock_scoreboard(game_id)
  end
end
