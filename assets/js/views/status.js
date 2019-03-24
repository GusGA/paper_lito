export default {
  status: {
    done: {
      classAdd: "bg-success",
      text: "Done",
      classRemove: ["bg-warning"]
    },
    pending: {
      classAdd: "bg-warning",
      text: "Pending",
      classRemove: ["bg-success"]
    },
    playing: {
      classAdd: "bg-info",
      text: "Playing",
      classRemove: ["bg-success", "bg-warning"]
    }
  },
  change: function (statusKey, nodeElem) {
    this.status[statusKey].classRemove.forEach(element => {
      nodeElem.classList.remove(element)
    });
    nodeElem.classList.add(this.status[statusKey].classAdd)
    nodeElem.innerText = this.status[statusKey].text
  }
}
