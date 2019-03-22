import MainView from "../main";
import socket from "../../socket";
import status from "../status"
export default class View extends MainView {

  buildStatus(teamsData) {
    teamsData.forEach(element => {
      let team_elem = document.getElementById(element.team_id)
      var node_elem = team_elem.getElementsByClassName("team-status")[0]
      this.hideActionButton(element, team_elem)
      status.change(element.team_status, node_elem)
    });
  }

  hideActionButton(payload, node) {
    if (payload.team_status === "done") {
      node.querySelectorAll(`a.${payload.team_id}`)[0].style.display = 'none'
    } else if (payload.team_status === "pending") {
      node.querySelectorAll(`a.${payload.team_id}`)[0].style.display = 'block'
    }
  }
  mount() {
    super.mount();
    var game_id = document.getElementById("game-id").getAttribute("data-game-id")
    let topic = `team_status:${game_id}`
    let channel = socket.channel(topic, {})
    channel.join()
      .receive("ok", data => {
        this.buildStatus(data)
        console.log(`Join to channel ${topic}`)
      })
      .receive("error", _resp => {
        console.log("Unable to join topic", _resp)
      })

    channel.on("update_teams_status", payload => {
      let team_elem = document.getElementById(payload.team_id)
      var elem = team_elem.getElementsByClassName("team-status")[0]
      hideActionButton(payload, team_elem)
      status.change(payload.team_status, elem)
    })

  }

  unmount() {
    super.unmount();

  }
}
