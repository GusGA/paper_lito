defmodule Papelito.Model.GameLog do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}

  schema "game_logs" do
    field(:slug, :string)
    field(:winner, :string)
    embeds_many(:teams, Papelito.TeamLog)
    embeds_many(:words, Papelito.WordLog)
    timestamps()
  end

  @doc false
  def changeset(%GameLog{} = game_log, attrs) do
    game_log
    |> cast(attrs, [:slug, :winner])
    |> cast_embed(:teams)
    |> cast_embed(:words)
    |> validate_required([:slug])
  end
end

defmodule Papelito.WordLog do
  use Ecto.Schema

  embedded_schema do
    field(:content)
  end
end

defmodule Papelito.TeamLog do
  use Ecto.Schema

  embedded_schema do
    field(:players)
    field(:name)
    field(:score)
  end
end
