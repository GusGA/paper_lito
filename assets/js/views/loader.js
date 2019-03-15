import MainView from "./main";
import GameNewView from "./game/new";
import GameShowView from "./game/show";
import TeamsShowView from "./teams/show";
// Collection of specific view modules
const views = {
  GameNewView,
  GameShowView,
  TeamsShowView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
