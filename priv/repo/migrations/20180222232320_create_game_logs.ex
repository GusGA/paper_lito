defmodule Papelito.Repo.Migrations.CreateGameLogs do
  use Ecto.Migration

  def change do
    create table(:game_logs, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:slug, :string)
      add(:winner, :string)
      add(:words, {:array, :map}, default: [])
      add(:teams, {:array, :map}, default: [])
      timestamps()
    end
  end
end