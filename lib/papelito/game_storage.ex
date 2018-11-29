defmodule Papelito.GameStorage do
  alias Papelito.GamePlay

  def setup do
    :ets.new(:game_table, [:set, :public, :named_table])
  end

  def fetch_game(game_name, subject) do
    case :ets.lookup(:game_table, game_name) do
      [] ->
        game = GamePlay.new(subject)
        :ets.insert(:game_table, {game_name, game})
        game

      [{^game_name, game}] ->
        game
    end
  end

  def save_game(game_name, game) do
    :ets.insert(:game_table, {game_name, game})
  end

  def delete_game(game_name) do
    :ets.delete(:game_table, game_name)
  end
end
