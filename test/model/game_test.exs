defmodule Papelito.Model.GameTest do
  use ExUnit.Case

  alias Papelito.Model.Game
  alias Papelito.Model.Team

  test "Create game" do
    game = %Game{subject: "Phrases", papers: [], teams: %{}}

    assert Game.create("Phrases") == game
  end

  test "Add team" do
    game = %Game{subject: "Phrases", papers: [], teams: %{}}
    team_one_name = "team_one"
    team_one = %Team{name: team_one_name, players: [], score: 0, id: "team_one"}

    game = Game.add_team(game, team_one_name)
    assert game.teams[team_one_name] == team_one

    team_two = %Team{name: "t_two", players: [], score: 0, id: "t_two"}
    team_three = %Team{name: "team_three", players: [], score: 0, id: "team_three"}
    game_a = Game.add_team(game, ["t_two", "team_three"])

    assert length(Map.keys(game_a.teams)) == 3
    assert game_a.teams["t_two"] == team_two
    assert game_a.teams["team_three"] == team_three
  end

  test "Add point to a specific team" do
    team_one = %Team{name: "t_one", players: [], score: 0}
    team_two = %Team{name: "t_two", players: [], score: 0}
    teams = %{"t_one" => team_one, "t_two" => team_two}
    game_a = %Game{subject: "phrases", papers: [], teams: teams}

    updated_game_a = Game.add_point_to_team(game_a, "t_one")
    assert updated_game_a.teams["t_one"].score == 1

    updated_game_b = Game.add_point_to_team(updated_game_a, "t_one")
    assert updated_game_b.teams["t_one"].score == 2

    updated_game_c = Game.add_point_to_team(updated_game_b, "t_two")
    assert updated_game_c.teams["t_two"].score == 1
    assert updated_game_c.teams["t_one"].score == 2
  end

  test "Winner" do
    team_one_a = %Team{name: "t_one", players: [], score: 10}
    team_two_a = %Team{name: "t_two", players: [], score: 15}
    teams = %{"t_one" => team_one_a, "t_two" => team_two_a}
    game_a = %Game{subject: "Phrases", papers: [], teams: teams}
    assert Game.winner(game_a) == [team_two_a]

    # Tie
    team_one_b = %Team{name: "t_one", players: [], score: 10}
    team_two_b = %Team{name: "t_two", players: [], score: 15}
    team_three_b = %Team{name: "t_three", players: [], score: 15}
    teams_b = %{"t_one" => team_one_b, "t_two" => team_two_b, "t_three" => team_three_b}
    game_b = %Game{subject: "phrases", papers: [], teams: teams_b}
    assert Game.winner(game_b) == [team_three_b, team_two_b]
  end

  test "Add papers" do
    one = "JK Simmons"
    two = "Fracisco de Miranda"
    three = "Elon Musk"

    team_one = %Team{name: "t_one", players: [], score: 0}
    team_two = %Team{name: "t_two", players: [], score: 0}
    teams = %{"t_one" => team_one, "t_two" => team_two}
    game = %Game{subject: "Characters", teams: teams, papers: []}

    game = Game.add_paper(game, one)
    assert game.papers == [one]

    game = Game.add_paper(game, [two, three])
    assert game.papers == [one, two, three]
  end
end
