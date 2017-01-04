export default class MainView {
  loaded() {
    console.log('MainView loaded');
  }

  unloaded() {
    console.log('MainView unloaded');
  }

  handleKeyPress(e) {
    console.log(e);
  }
}

