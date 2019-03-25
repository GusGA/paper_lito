defmodule Papelito.Model.Game do
  alias __MODULE__
  alias Papelito.Model.Team

  defstruct teams: %{}, papers: []

  @type t :: %__MODULE__{
          teams: map(),
          papers: [String.t()]
        }

  @spec create() :: Game.t()
  def create() do
    %Game{}
  end

  def add_team(%Game{} = game, team_name) when is_binary(team_name) do
    name = sanitize_team_name(team_name)
    teams = Map.put(game.teams, name, Team.create(team_name))
    %Game{game | teams: teams}
  end

  @spec add_team(Game.t(), Enumerable.t()) :: Game.t()
  def add_team(%Game{} = game, teams_name) when is_list(teams_name) do
    teams =
      Enum.map(teams_name, fn team_name ->
        {sanitize_team_name(team_name), Team.create(team_name)}
      end)
      |> Map.new()
      |> Map.merge(game.teams)

    %Game{game | teams: teams}
  end

  @spec add_point_to_team(Game.t(), String.t()) :: Game.t()
  def add_point_to_team(%Game{} = game, team_name) do
    team = Team.add_point(game.teams[team_name])
    teams = Map.put(game.teams, team_name, team)
    %Game{game | teams: teams}
  end

  def winner(%Game{} = game) do
    teams = Map.values(game.teams)
    max_score = Enum.map(teams, fn team -> team.score end) |> Enum.max()
    Enum.filter(teams, fn team -> team.score == max_score end)
  end

  def add_paper(%Game{} = game, paper) when is_binary(paper) do
    %Game{game | papers: [paper | game.papers]}
  end

  @spec add_paper(Game.t(), Enumerable.t()) :: Game.t()
  def add_paper(%Game{} = game, papers) when is_list(papers) do
    %Game{game | papers: Enum.into(papers, game.papers)}
  end

  ## -------------------##
  ## Helpers functions ##
  ## -------------------##

  @spec sanitize_team_name(String.t()) :: String.t()
  def sanitize_team_name(name) do
    Papelito.Utils.Sanitizer.clean(name)
  end
end
