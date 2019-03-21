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
    }
  },
  change: function (statusKey, nodeElem, callback = null) {
    nodeElem.classList.remove(this.status[statusKey].classRemove)
    nodeElem.classList.add(this.status[statusKey].classAdd)
    nodeElem.innerText = this.status[statusKey].text

    if (typeof callback === "function") {
      callback()
    }
  }
}
