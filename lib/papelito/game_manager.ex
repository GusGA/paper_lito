defmodule Papelito.GameManager do
  require Logger

  alias Papelito.GamePlay
  alias Papelito.Model.{Game, GameLog}
  alias Papelito.Repo

  def new_game do
    game_name = Haikunator.build()

    case Papelito.Supervisor.GameSupervisor.start_game(game_name) do
      {:ok, _} -> {:name, game_name}
      {:error, _} -> new_game
    end
  end

  def summary(game_name) do
    Papelito.Server.Game.summary(game_name)
  end

  def add_teams(game_name, teams) when is_list(teams) do
    create_teams(game_name, teams)
    add_players(game_name, teams)
  end

  def add_papers(game_name, papers) when is_list(papers) do
    Enum.map(papers, fn paper ->
      Papelito.Server.Game.add_paper(game_name, paper)
    end)
  end

  def mark_papers_added(game_name, team_name) do
    Papelito.Server.Game.mark_papers_added(game_name, team_name)
  end

  def alive?(game_name) do
    case Papelito.Server.Game.pid(game_name) do
      nil ->
        false

      pid when is_pid(pid) ->
        Process.alive?(pid)
    end
  end

  def create_game_log(game_name) do
    GameLog.changeset(%GameLog{}, %{slug: game_name})
    |> Repo.insert()
  end

  def save_game_log(game_name) do
    Papelito.Server.Game.summary(game_name)
    |> build_game_log(game_name)
    |> (&GameLog.changeset(%GameLog{}, &1)).()
    |> Repo.update()
  end

  def build_game_log(%GamePlay{} = game_play, game_name) do
    log = fetch_log(game_name)

    %{
      id: log.id,
      slug: game_name,
      winner: Enum.join(Game.winner(game_play.game), ","),
      teams: game_play.game.teams,
      words: game_play.game.papers
    }
  end

  def fetch_log(game_name) do
    Repo.get_by(GameLog, slug: game_name)
  end

  def delete_game(game_name) do
    Logger.info("Deleting game #{game_name}")
    Papelito.Server.Game.terminate(game_name)
  end

  def create_teams(game_name, teams) do
    teams
    |> Enum.map(fn t_data -> t_data[:name] end)
    |> Enum.map(fn t_name ->
      Task.async(fn -> Papelito.Server.Game.add_team(game_name, t_name) end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def add_players(game_name, teams) do
    teams
    |> Enum.map(fn t_data ->
      Task.async(fn ->
        Papelito.Server.Game.add_player(game_name, t_data[:key], t_data[:players])
      end)
    end)
    |> Enum.map(&Task.await/1)
  end
end
