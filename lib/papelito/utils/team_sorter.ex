defmodule Papelito.Utils.TeamSorter do
  alias Papelito.Utils.TeamNameGenerator

  def perform(players, team_qty) when is_list(players) and is_number(team_qty) do
    div_ = div(length(players), team_qty)
    rem_ = rem(length(players), team_qty)
    number_of_players_per_team = max(div_, rem_)

    teams_randomized =
      Enum.shuffle(players)
      |> Enum.chunk_every(number_of_players_per_team)

    teams_randomized =
      case div_ == 1 and rem_ == 1 do
        true ->
          [[first], [second] | tail] = teams_randomized
          [[first, second] | tail]

        false ->
          teams_randomized
      end

    TeamNameGenerator.generate(team_qty)
    |> Enum.zip(teams_randomized)
  end
end
