import MainView from '../main';
import {get, jsonReq} from "../request_helpers"
import * as view from "../view_helpers"

export default class View extends MainView {
  loaded() {
    super.loaded();
    console.log('loaded');
  }

  unloaded() {
    super.unloaded();
    console.log('loaded');
  }

  //handleKeyPress(e) {
    //super.handleKeyPress(e);

    //e = e || window.event;
    //// Escape should cancel our current edit.
    //if (e.keyCode == 27) {
      //cancelTransactionInEdit();
    //}
  //}
}

