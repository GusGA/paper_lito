defmodule PapelitoWeb.GameCommander do
  use Drab.Commander
  # Place your event handlers here
  #
  # defhandler button_clicked(socket, sender) do
  #   set_prop socket, "#output_div", innerHTML: "Clicked the button!"
  # end
  #
  # Place you callbacks here
  #
  # onload :page_loaded
  #
  # def page_loaded(socket) do
  #   set_prop socket, "div.jumbotron h2", innerText: "This page has been drabbed"
  # end

  defhandler add_player(socket, sender) do
    name = sender.params["player_name"]

    case name do
      "" ->
        nil

      _ ->
        {:ok, players} = Drab.Live.peek(socket, :players)
        Drab.Live.poke(socket, players: players ++ [%{index: length(players), name: name}])
    end
  end

  defhandler delete_player(socket, _sender, index) do
    {:ok, players} = Drab.Live.peek(socket, :players)

    filters_players =
      Enum.filter(players, fn %{index: player_index, name: _name} ->
        player_index != index
      end)

    Drab.Live.poke(socket, players: filters_players)
  end
end
