import MainView from "../main";
import socket from "../../socket"

export default class View extends MainView {

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
