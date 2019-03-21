import MainView from "../main";
import socket from "../../socket";
import status from "../status"
export default class View extends MainView {

  buildStatus(teamsData) {
    teamsData.forEach(element => {
      let team_elem = document.getElementById(element.team_id)
      var node_elem = team_elem.getElementsByClassName("team-status")[0]
      status.change(element.team_status, node_elem)
    });
  }
  mount() {
    super.mount();
    var game_id = document.getElementById("game-id").getAttribute("data-game-id")
    let topic = "team_status:" + game_id
    let channel = socket.channel(topic, {})
    channel.join()
      .receive("ok", data => {
        this.buildStatus(data)
      })
      .receive("error", _resp => {
        console.log("Unable to join topic", _resp)
      })

    channel.on("update_teams_status", payload => {
      console.log(payload)
      let team_elem = document.getElementById(payload.team)
      var elem = team_elem.getElementsByClassName("team-status")[0]
      status.change(payload.status, elem)
    })

  }

  unmount() {
    super.unmount();

  }
}
