import MainView from "../main";
import socket from "../../socket"
import status from "../status"

export default class View extends MainView {

  buildStatus(teamData) {
    Object.keys(teamData.players).forEach(playerName => {
      var player_elem = document.getElementById(playerName)
      var elem = player_elem.getElementsByClassName("player-status")[0]
      status.change(teamData.players[playerName], elem)
      this.hideActionButton(playerName, teamData.players[playerName], player_elem)
    })
  }

  hideActionButton(playerName, status, node) {
    var actionNode = node.querySelectorAll(`a.${playerName}`)[0]
    if (status === "done") {
      actionNode.style.display = 'none'
    } else if (status === "pending") {
      actionNode.style.display = 'inline-block'
    }
  }

  mount() {
    super.mount();
    var game_id = document.getElementById("team_show").dataset.gameId
    var team_id = document.getElementById("team_show").dataset.teamId
    var topic = "players_status:" + team_id
    let channel = socket.channel(topic, { game_id: game_id })

    channel.join()
      .receive("ok", data => {
        this.buildStatus(data)
        console.log("Joined topic", topic)
      })
      .receive("error", _resp => {
        console.log("Unable to join topic", topic)
      })

    channel.on("update_status", payload => {
      let player_elem = document.getElementById(payload.player)
      var elem = player_elem.getElementsByClassName("player-status")[0]
      this.hideActionButton(payload.player, payload.status, player_elem)
      status.change(payload.status, elem)
    })
  }

  unmount() {
    super.unmount();

    // Specific logic here
  }
}