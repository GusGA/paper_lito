defmodule Papelito.Utils.Sanitizer do
  @spec clean(String.t()) :: String.t()
  def clean(name) do
    name
    |> String.normalize(:nfd)
    |> String.downcase()
    |> String.replace(~r/[^A-z\s]/u, "")
    |> String.replace(~r/\s/, "-")
  end
end
