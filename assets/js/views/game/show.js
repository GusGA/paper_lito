import MainView from "../main";
import socket from "../../socket";
export default class View extends MainView {
  constructor() {
    super()
    this.status = {}
  }

  buildStatus(teamsData) {

  }

  changeStatus(status, domElem) {

  }

  mount() {
    super.mount();
    var topic = ""
    let game_id = null
    let channel = socket.channel(topic, {})
    channel.join()
      .receive("ok", data => {
        console.log(data)
      })
      .receive("error", _resp => {
        console.log("Unable to join topic", topic)
      })

    channel.on("update_teams_status", payload => {
      console.log(payload)
    })

  }

  unmount() {
    super.unmount();

  }
}
