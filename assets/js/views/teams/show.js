import MainView from "../main";
import socket from "../../socket"

export default class View extends MainView {
  mount() {
    super.mount();
    var topic = "players_status:" + document.getElementById("team_show").getAttribute("data-team-id")
    let channel = socket.channel(topic, {})
    channel.join()
      .receive("ok", data => {
        console.log("Joined topic", topic)
      })
      .receive("error", resp => {
        console.log("Unable to join topic", topic)
      })

    channel.on("update_status", payload => {
      console.log("Update:", payload);
    })
  }

  unmount() {
    super.unmount();

    // Specific logic here
  }
}
