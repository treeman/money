import loadView from './views/loader';

function handleDOMContentLoaded() {
  const viewName = document.getElementsByTagName('body')[0].dataset.jsViewName;
  const ViewClass = loadView(viewName);
  const view = new ViewClass();
  view.loaded();
  window.currentView = view;
}

function handleDocumentUnload() {
  window.currentView.unloaded();
}

function handleDOMKeyPress(e) {
  window.currentView.handleKeyPress(e);
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
window.addEventListener('unload', handleDocumentUnload, false);
window.addEventListener("keypress", handleDOMKeyPress, false);

