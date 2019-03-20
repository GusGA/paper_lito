import MainView from "../main";
import socket from "../../socket"

export default class View extends MainView {
  constructor() {
    super()
    this.status = {}
  }

  buildStatus(teamData) {
    this.status = Object.assign(this.status, teamData.players)
    Object.entries(this.status).forEach(entry => {
      let player_elem = document.getElementById(entry[0])
      var elem = player_elem.getElementsByClassName("player-status")[0]
      this.changeStatus(entry[1], elem)
    })
  }

  changeStatus(statusKey, domElem) {
    let status = {
      done: {
        classAdd: "bg-success",
        text: "Done",
        classRemove: "bg-warning"
      },
      pending: {
        classAdd: "bg-warning",
        text: "Pending",
        classRemove: "bg-success"
      }
    }
    domElem.classList.remove(status[statusKey].classRemove)
    domElem.classList.add(status[statusKey].classAdd)
    domElem.innerText = status[statusKey].text
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
      this.changeStatus(payload.status, elem)
    })
  }

  unmount() {
    super.unmount();

    // Specific logic here
  }
}
