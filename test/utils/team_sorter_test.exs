defmodule Papelito.Utils.TeamSorterTest do
  use ExUnit.Case

  alias Papelito.Utils.{TeamNameGenerator, TeamSorter}

  test "Randomize players in teams" do
    teams_qty = 3
    players = ?A..?D |> Enum.map(&List.to_string([&1]))

    TeamSorter.perform(players, teams_qty)
    |> Enum.each(fn {_, team} ->
      case length(team) == div(length(players), teams_qty) do
        true -> assert true
        false -> assert length(team) == div(length(players), teams_qty) + 1
      end
    end)
  end
end
