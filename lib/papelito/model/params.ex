defmodule Papelito.Params do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "params" do
    field(:players, {:array, :string})
    field(:teams_qty, :integer)
    field(:papers_per_player, :integer)
  end

  def changeset(%Params{} = params, attrs \\ %{}) do
    params
    |> cast(attrs, [:players, :teams_qty, :papers_per_player])
  end
end
