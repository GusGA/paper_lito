defmodule Papelito.Model.TeamTest do
  use ExUnit.Case

  alias Papelito.Model.Team

  test "Create team" do
    team = %Team{name: "some_name", players: [], score: 0, id: "some_name"}

    assert(Papelito.Model.Team.create("some_name") == team)
  end

  test "Add players" do
    team = %Team{name: "some_name", players: [], score: 0, id: "some_name"}

    with_one_player = ["player_one"]
    with_two_players = ["player_two", "player_one"]

    team_with_one_player = Team.add_player(team, "player_one")

    assert team_with_one_player.players == with_one_player

    team_with_two_players = Team.add_player(team_with_one_player, "player_two")

    assert team_with_two_players.players == with_two_players
  end

  test "Update score" do
    team = %Team{name: "some_name", players: [], score: 0}

    team_with_one_point = Team.add_point(team)

    assert team_with_one_point.score == 1

    team_with_two_points = Team.add_point(team_with_one_point)

    assert team_with_two_points.score == 2
  end
end
