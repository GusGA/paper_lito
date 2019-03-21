import MainView from "../main";
import socket from "../../socket"
import status from "../status"

export default class View extends MainView {

  buildStatus(teamData) {
    Object.entries(teamData.players).forEach(entry => {
      let player_elem = document.getElementById(entry[0])
      var elem = player_elem.getElementsByClassName("player-status")[0]
      status.change(entry[1], elem)
    })
  }

  checkTeamStatus(game_id, team_id, channel) {
    channel.push("check_team_status", { game_id: game_id, team_id: team_id })
      .receive("ok", data => {
        this.buildStatus(data)
      })
      .receive("error", res => {
        console.log(`Unable to check ${team_id} status`)
      })
  }
  mount() {
    super.mount();
    var game_id = document.getElementById("team_show").getAttribute("data-game-id")
    var team_id = document.getElementById("team_show").getAttribute("data-team-id")
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
      status.change(payload.status, elem, this.checkTeamStatus(game_id, team_id, channel))
    })
  }

  unmount() {
    super.unmount();

    // Specific logic here
  }
}
