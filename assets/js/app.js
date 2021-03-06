// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import LiveSocket from "phoenix_live_view"
import jquery from "jquery";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import loadView from "./views/loader";

function handleDOMContentLoaded() {
  // Get the current view name
  const viewName = document.getElementsByTagName("body")[0].dataset.jsViewName;

  // Load view class and mount it
  const ViewClass = loadView(viewName);
  const view = new ViewClass();
  view.mount();

  let liveSocket = new LiveSocket("/live")
  liveSocket.connect()
  window.currentView = view;
}

function handleDocumentUnload() {
  window.currentView.unmount();
}

window.addEventListener("DOMContentLoaded", handleDOMContentLoaded, false);
window.addEventListener("unload", handleDocumentUnload, false);