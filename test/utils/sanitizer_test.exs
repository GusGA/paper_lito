defmodule Papelito.Utils.SanitizerTest do
  use ExUnit.Case

  test "Remove accents chars" do
    assert Papelito.Utils.Sanitizer.clean("Hubert Łępicki") == "hubert-epicki"
    assert Papelito.Utils.Sanitizer.clean("árboles más grandes") == "arboles-mas-grandes"

    assert Papelito.Utils.Sanitizer.clean("Übel wütet der Gürtelwürger") ==
             "ubel-wutet-der-gurtelwurger"
  end
end
