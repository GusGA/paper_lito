defmodule Papelito.Events.Team.Manager do
  alias Papelito.Server.Status.Team, as: StatusServer
  require Logger

  @pubsub_scoreboard_name :scoreboard

  def subscribe_score_board_live_view(game_name) do
    Phoenix.PubSub.subscribe(@pubsub_scoreboard_name, game_name, link: true)
  end

  def notify_game_play_changes(game_name, :update_scoreboard) do
    Logger.debug("Entre para hacer broadcast")
    Phoenix.PubSub.broadcast(@pubsub_scoreboard_name, game_name, :update_scoreboard)
  end

  def update_player_status({team_name, player_name, status}) do
    StatusServer.update_player(team_name, player_name, status)

    PapelitoWeb.PlayersStatusChannel.broadcast_update_status(
      team_name,
      player_name,
      status
    )
  end

  def update_team_status({team_name, status}) do
    StatusServer.update_team(team_name, status)
  end

  def broadcast_team_status({team_name, game_name, status}) do
    PapelitoWeb.TeamStatusChannel.broadcast_update_status(team_name, game_name, status)
  end
end
