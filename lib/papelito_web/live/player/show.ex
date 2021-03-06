defmodule PapelitoWeb.PlayerLive.Show do
  use Phoenix.LiveView
  alias PapelitoWeb.Router.Helpers, as: Routes
  alias Papelito.Server.Lock.Team, as: LockServer
  alias Papelito.GameManager

  def mount(
        %{
          path_params: %{
            "game_id" => game_id,
            "player_name" => player_name,
            "team_id" => team_id
          }
        },
        socket
      ) do
    case GameManager.alive?(game_id) && part_of_team?(game_id, team_id, player_name) &&
           !LockServer.player_locked?(team_id, player_name) do
      true ->
        team_data = fetch_team_summary(game_id, team_id)
        max_papers = max_papers(game_id)

        {:ok,
         assign(
           socket,
           %{
             papers: [],
             player_name: player_name,
             team_name: team_data.name,
             game_id: game_id,
             team_id: team_id,
             max_papers: max_papers
           }
         )}

      false ->
        {:stop,
         socket
         |> put_flash(:info, "The papers were added sucessfully")
         |> redirect(
           to:
             Routes.teams_path(
               %Plug.Conn{},
               :show,
               game_id,
               team_id
             )
         )}
    end
  end

  def render(assigns) do
    PapelitoWeb.PlayerView.render("show.html", assigns)
  end

  def handle_event("add_paper", %{"params" => %{"paper" => paper}} = _params, socket) do
    papers =
      case paper do
        "" ->
          socket.assigns.papers

        paper ->
          socket.assigns.papers ++ [paper]
      end

    {:noreply,
     assign(
       socket,
       %{
         papers: papers,
         player_name: socket.assigns.player_name,
         team_name: socket.assigns.team_name,
         game_id: socket.assigns.game_id,
         team_id: socket.assigns.team_id,
         max_papers: socket.assigns.max_papers
       }
     )}
  end

  def handle_event("delete_paper", value, socket) do
    {index, _} = Integer.parse(value)
    papers = List.delete_at(socket.assigns.papers, index)

    {:noreply,
     assign(
       socket,
       %{
         papers: papers,
         player_name: socket.assigns.player_name,
         team_name: socket.assigns.team_name,
         team_id: socket.assigns.team_id,
         game_id: socket.assigns.game_id
       }
     )}
  end

  def handle_event("save_papers", _values, socket) do
    case Papelito.GameManager.alive?(socket.assigns.game_id) do
      true ->
        Papelito.GameManager.add_papers(socket.assigns.game_id, socket.assigns.papers)

        Papelito.Events.Team.Manager.update_player_status(
          {socket.assigns.team_id, socket.assigns.player_name, "done"}
        )

        Papelito.LockManager.lock_player(socket.assigns.team_id, socket.assigns.player_name)

        {:stop,
         socket
         |> put_flash(:info, "The papers were added sucessfully")
         |> redirect(
           to:
             Routes.teams_path(
               %Plug.Conn{},
               :show,
               socket.assigns.game_id,
               socket.assigns.team_id
             )
         )}

      false ->
        {:stop,
         socket
         |> put_flash(:error, "The game does not exist, please create a new one")
         |> redirect(to: Routes.page_path(%Plug.Conn{}, :index))}
    end
  end

  defp fetch_team_summary(game_id, team_id) do
    summary = Papelito.GameManager.summary(game_id)
    summary.game.teams[team_id]
  end

  defp max_papers(game_id) do
    Papelito.GameManager.papers_per_player(game_id)
  end

  def part_of_team?(game_id, team_id, player_name) do
    team = fetch_team_summary(game_id, team_id)
    Enum.member?(team.players, player_name)
  end
end
