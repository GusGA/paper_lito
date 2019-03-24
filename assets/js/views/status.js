export default {
  status: {
    done: {
      classAdd: "bg-success",
      text: "Done",
      classRemove: "bg-warning"
    },
    pending: {
      classAdd: "bg-warning",
      text: "Pending",
      classRemove: "bg-success"
    },
    playing: {
      classAdd: "bg-info",
      text: "Playing",
      classRemove: ["bg-success", "bg-warning"]
    }
  },
  change: function (statusKey, nodeElem) {
    nodeElem.classList.remove(this.status[statusKey].classRemove)
    nodeElem.classList.add(this.status[statusKey].classAdd)
    nodeElem.innerText = this.status[statusKey].text
  }
}
