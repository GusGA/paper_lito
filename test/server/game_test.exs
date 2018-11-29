defmodule Papelito.Server.GameTest do
  use ExUnit.Case, async: true
  alias Papelito.GamePlay
  alias Papelito.Model.Team

  setup_all _context do
    on_exit(fn ->
      :ets.delete(:game_table)
    end)

    {:ok, []}
  end

  test "Init Server" do
    {:ok, state, _timeout} = Papelito.Server.Game.init({Haikunator.build(), "Rock Bands"})
    assert state.game.subject == "Rock Bands"
    assert state.round == 0
    assert is_nil(state.current_paper)
  end

  test "Start game" do
    {:ok, state, _timeout} = Papelito.Server.Game.init({Haikunator.build(), "Rock Bands"})
    {:reply, :ok, new_state, _timeout} = Papelito.Server.Game.handle_call(:start, nil, state)
    assert new_state.round == 1
  end

  test "Next team" do
    game_state = %GamePlay{teams_order: ["team_two", "team_one", "team_three"]}

    {:reply, team, new_state, _timeout} =
      Papelito.Server.Game.handle_call(:next_team, nil, game_state)

    assert team == "team_two"
    assert new_state.current_team == "team_two"

    {:reply, team, new_x2_state, _timeout} =
      Papelito.Server.Game.handle_call(:next_team, nil, new_state)

    assert team == "team_one"
    assert new_x2_state.current_team == "team_one"

    {:reply, team, new_x3_state, _timeout} =
      Papelito.Server.Game.handle_call(:next_team, nil, new_x2_state)

    assert team == "team_three"
    assert new_x3_state.current_team == "team_three"

    {:reply, team, new_x4_state, _timeout} =
      Papelito.Server.Game.handle_call(:next_team, nil, new_x3_state)

    assert team == "team_two"
    assert new_x4_state.current_team == "team_two"
  end

  test "Add Team" do
    game_state = %GamePlay{}
    team_one = %Team{name: "team_one", players: [], score: 0, id: "team_one"}

    {:noreply, new_state, _timeout} =
      Papelito.Server.Game.handle_cast({:add_team, "team_one"}, game_state)

    assert new_state.game.teams["team_one"] == team_one

    team_two = %Team{name: "team_two", players: [], score: 0, id: "team_two"}

    {:noreply, new_new_state, _timeout} =
      Papelito.Server.Game.handle_cast({:add_team, "team_two"}, new_state)

    assert new_new_state.game.teams["team_one"] == team_one
    assert new_new_state.game.teams["team_two"] == team_two
  end

  test "Next Round" do
    previous_papers = ["Paper 1", "Paper 2", "Paper 3"]
    game_state = %GamePlay{previous_papers: previous_papers}

    {:reply, round1, state_one, _timeout} =
      Papelito.Server.Game.handle_call(:next_round, nil, game_state)

    assert round1 == 1
    assert state_one.round == round1
    assert state_one.previous_papers == []

    {:reply, round2, state_two, _timeout} =
      Papelito.Server.Game.handle_call(:next_round, nil, %GamePlay{
        state_one
        | previous_papers: previous_papers
      })

    assert round2 == 2
    assert state_two.round == round2
    assert state_two.previous_papers == []

    {:reply, round3, state_three, _timeout} =
      Papelito.Server.Game.handle_call(:next_round, nil, %GamePlay{
        state_two
        | previous_papers: previous_papers
      })

    assert round3 == 3
    assert state_three.round == round3
    assert state_three.previous_papers == []

    # Round 4 == End game but still playing
    {:reply, round4, state_four, _timeout} =
      Papelito.Server.Game.handle_call(:next_round, nil, %GamePlay{
        state_three
        | previous_papers: previous_papers
      })

    assert round4 == 0
    assert state_four.round == round4
    assert state_three.previous_papers == []
  end

  test "Paper[Add]" do
    game_state = %GamePlay{}
    paper_one = "JK Simmons"

    {:reply, paper_one, state_one, _timeout} =
      Papelito.Server.Game.handle_call({:add_paper, paper_one}, nil, game_state)

    assert state_one.game.papers == [paper_one]

    paper_two = "Harry Potter"

    {:reply, paper_two, state_two, _timeout} =
      Papelito.Server.Game.handle_call({:add_paper, paper_two}, nil, state_one)

    assert state_two.game.papers == [paper_two, paper_one]
  end

  test "Paper[Fetch]" do
    game_state = %GamePlay{}
    papers = ["JK Simmons", "Harry Potter"]

    {:reply, papers, state_one, _timeout} =
      Papelito.Server.Game.handle_call({:add_paper, papers}, nil, game_state)

    {:reply, paper, state_two, _timeout} =
      Papelito.Server.Game.handle_call(:fetch_paper, nil, state_one)

    assert is_binary(paper)
    assert Enum.member?(papers, paper)
    assert state_two.current_paper == paper
    assert length(state_two.previous_papers) == 0

    {:reply, paper_a, state_three, _timeout} =
      Papelito.Server.Game.handle_call(:fetch_paper, nil, state_two)

    assert is_binary(paper_a)
    assert Enum.member?(papers, paper_a)
    assert state_three.current_paper == paper_a
    assert length(state_three.previous_papers) == 1

    {:reply, nil, state_four, _timeout} =
      Papelito.Server.Game.handle_call(:fetch_paper, nil, state_three)

    assert state_four.current_paper == nil
    assert length(state_four.previous_papers) == 2
  end

  test "Add Player" do
    game_state = %GamePlay{}
    [player_one, player_two, player_one_b, player_two_b] = ["Marceline", "BMO", "Finn", "Jake"]

    {:noreply, new_state, _timeout} =
      Papelito.Server.Game.handle_cast({:add_team, ["team_one", "team_two"]}, game_state)

    {:noreply, new_new_state, _timeout} =
      Papelito.Server.Game.handle_cast({:add_player, "team_one", player_one}, new_state)

    assert new_new_state.game.teams["team_one"].players == [player_one]

    {:noreply, new_x3_state, _timeout} =
      Papelito.Server.Game.handle_cast({:add_player, "team_one", player_two}, new_new_state)

    assert new_x3_state.game.teams["team_one"].players == [player_two, player_one]

    {:noreply, new_x4_state, _timeout} =
      Papelito.Server.Game.handle_cast({:add_player, "team_two", player_one_b}, new_x3_state)

    assert new_x4_state.game.teams["team_two"].players == [player_one_b]

    {:noreply, new_x5_state, _timeout} =
      Papelito.Server.Game.handle_cast({:add_player, "team_two", player_two_b}, new_x4_state)

    assert new_x5_state.game.teams["team_two"].players == [player_two_b, player_one_b]
  end

  test "Add point" do
    game_state = %GamePlay{}

    {:noreply, new_state, _timeout} =
      Papelito.Server.Game.handle_cast({:add_team, "team_one"}, game_state)

    {:noreply, new_new_state, _timeout} =
      Papelito.Server.Game.handle_cast({:add_team, "team_two"}, new_state)

    {:noreply, new_x3_state, _timeout} =
      Papelito.Server.Game.handle_cast({:add_point, "team_one"}, new_new_state)

    assert new_x3_state.game.teams["team_one"].score == 1
    assert new_x3_state.game.teams["team_two"].score == 0

    {:noreply, new_x4_state, _timeout} =
      Papelito.Server.Game.handle_cast({:add_point, "team_one"}, new_x3_state)

    assert new_x4_state.game.teams["team_one"].score == 2
    assert new_x4_state.game.teams["team_two"].score == 0

    {:noreply, new_x5_state, _timeout} =
      Papelito.Server.Game.handle_cast({:add_point, "team_two"}, new_x4_state)

    assert new_x5_state.game.teams["team_one"].score == 2
    assert new_x5_state.game.teams["team_two"].score == 1
  end
end
