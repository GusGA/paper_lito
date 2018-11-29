defmodule Papelito.Utils.TeamNameGeneratorTest do
  use ExUnit.Case

  test "Always random and unique team names" do
    assert length(Papelito.Utils.TeamNameGenerator.generate(5)) == 5
    assert length(Papelito.Utils.TeamNameGenerator.generate(10)) == 10
    assert length(Papelito.Utils.TeamNameGenerator.generate(20)) == 20
    assert length(Papelito.Utils.TeamNameGenerator.generate(30)) == 30
  end
end
