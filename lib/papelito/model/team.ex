defmodule Papelito.Model.Team do
  alias __MODULE__
  @derive Jason.Encoder
  defstruct players: [], score: 0, name: "", id: "", papers_added: false

  @type t :: %__MODULE__{
          id: String.t(),
          players: [String.t()],
          name: String.t(),
          score: integer,
          papers_added: boolean
        }

  @spec create(String.t()) :: Team.t()
  def create(name) do
    %Team{name: name, id: Papelito.Utils.Sanitizer.clean(name)}
  end

  @spec add_point(Team.t()) :: Team.t()
  def add_point(%Team{} = team) do
    Map.put(team, :score, team.score + 1)
  end

  @spec add_player(Team.t(), String.t()) :: Team.t()
  def add_player(%Team{} = team, player_name) when is_binary(player_name) do
    players = [player_name | team.players]
    %Team{team | players: players}
  end

  @spec add_player(Team.t(), Enumerable.t()) :: Team.t()
  def add_player(%Team{} = team, players_name) when is_list(players_name) do
    players = Enum.into(players_name, team.players)
    %Team{team | players: players}
  end

  @spec papers_added(Team.t()) :: Team.t()
  def papers_added(%Team{} = team) do
    Map.put(team, :papers_added, true)
  end
end
