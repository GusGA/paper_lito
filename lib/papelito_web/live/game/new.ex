defmodule PapelitoWeb.GameLive.New do
  use Phoenix.LiveView
  alias Papelito.Params
  alias PapelitoWeb.Router.Helpers, as: Routes

  def mount(_session, socket) do
    {:ok,
     assign(
       socket,
       %{
         changeset: Params.changeset(%Params{}),
         players: [],
         teams_qty: nil,
         sorted_teams: nil,
         papers_per_player: 4
       }
     )}
  end

  def render(assigns), do: PapelitoWeb.GameView.render("new.html", assigns)

  def handle_event(
        "teams_qty_change",
        %{"params" => %{"teams_qty" => teams_qty}} = params,
        socket
      ) do
    qty = set_team_qty(teams_qty, socket.assigns.changeset.data)
    players = socket.assigns.players
    papers_per_player = socket.assigns.papers_per_player

    {:noreply,
     assign(
       socket,
       %{
         changeset:
           Params.changeset(%Params{}, %{
             players: players,
             teams_qty: qty
           }),
         players: players,
         teams_qty: qty,
         papers_per_player: papers_per_player,
         sorted_teams: socket.assigns.sorted_teams
       }
     )}
  end

  def handle_event(
        "add_player",
        %{"params" => %{"player_name" => name, "teams_qty" => teams_qty}} = _params,
        socket
      ) do
    players =
      case name do
        "" -> socket.assigns.players
        _ -> socket.assigns.players ++ [name]
      end

    qty = set_team_qty(teams_qty, socket.assigns.changeset.data)

    {:noreply,
     assign(
       socket,
       %{
         changeset: Params.changeset(%Params{}, %{players: players, teams_qty: qty}),
         players: players,
         teams_qty: qty,
         sorted_teams: socket.assigns.sorted_teams
       }
     )}
  end

  def handle_event("delete", value, socket) do
    {index, _} = Integer.parse(value)
    players = List.delete_at(socket.assigns.players, index)
    teams_qty = socket.assigns.teams_qty

    {:noreply,
     assign(
       socket,
       %{
         changeset: Params.changeset(%Params{}, %{players: players, teams_qty: teams_qty}),
         players: players,
         teams_qty: teams_qty,
         sorted_teams: socket.assigns.sorted_teams
       }
     )}
  end

  def handle_event("sort_player", _value, socket) do
    players = socket.assigns.players
    teams_qty = socket.assigns.teams_qty
    sorted_teams = Papelito.Utils.TeamSorter.perform(players, teams_qty)
    papers_per_player = socket.assigns.papers_per_player

    {:noreply,
     assign(
       socket,
       %{
         changeset:
           Params.changeset(%Params{}, %{
             players: players,
             teams_qty: teams_qty,
             papers_per_player: papers_per_player
           }),
         players: players,
         teams_qty: teams_qty,
         sorted_teams: sorted_teams,
         papers_per_player: papers_per_player
       }
     )}
  end

  def handle_event("create_game", _value, socket) do
    game_data = create_game(socket.assigns.sorted_teams, socket.assigns.papers_per_player)

    {:stop,
     socket
     |> put_flash(:info, "Game created")
     |> redirect(to: Routes.game_path(%Plug.Conn{}, :show, game_data.game_name))}
  end

  defp set_team_qty(nil, _), do: nil

  defp set_team_qty(teams_qty, data) do
    {value, _} = Integer.parse(teams_qty)

    case data.teams_qty do
      nil ->
        value

      qty ->
        if qty != value do
          value
        else
          qty
        end
    end
  end

  defp create_game(sorted_teams, papers_per_player) do
    {:name, name} = Papelito.GameManager.new_game(papers_per_player)
    Papelito.GameManager.add_teams(name, sorted_teams)
    summary = Papelito.GameManager.summary(name)

    %{game_name: name, summary: summary}
  end

  def terminate(_reason, _socket) do
    :ok
  end
end
