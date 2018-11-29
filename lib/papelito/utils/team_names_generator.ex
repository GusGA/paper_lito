defmodule Papelito.Utils.TeamNameGenerator do
  @adjetives Application.get_env(:papelito, :team_names)[:adjetives]
  @animals Application.get_env(:papelito, :team_names)[:animals]

  def generate do
    [@adjetives, @animals]
    |> Enum.map(&sample/1)
    |> Enum.join(" ")
    |> add_the_article()
  end

  def generate(n) when is_integer(n) do
    Enum.reduce(1..n, [], fn _, acc ->
      generate() |> generate_name(acc)
    end)
  end

  defp generate_name(name, acc) do
    case Enum.member?(acc, name) do
      true -> generate() |> generate_name(acc)
      false -> [name | acc]
    end
  end

  defp sample(array), do: Enum.random(array)

  defp add_the_article(name), do: "The #{name}"
end
