import MainView from '../main';
import {get, jsonReq} from "../request_helpers"
import * as view from "../view_helpers"

export default class View extends MainView {
  loaded() {
    super.loaded();
    console.log('loaded');

    registerArrowCB();
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

function registerArrowCB() {
  var divs = document.querySelectorAll('.grid-budget-arrow');
  for (var div of divs) {
      div.addEventListener('click', toggleGroupExpand);
  }
  //console.log(divs);
}

function toggleGroupExpand(e) {
  var curr = this.innerHTML;
  var categories = collectCategories(this.parentNode);
  if (curr == "▼") {
    this.innerHTML = "►";
    for (var category of categories) {
      category.style.display = 'none';
    }
  } else {
    this.innerHTML = "▼";
    for (var category of categories) {
      category.style.display = '';
    }
  }
}

function collectCategories(groupRow) {
  var categories = [];
  var currNode = groupRow.nextElementSibling;
  while (currNode && currNode.classList.contains('budgeted-category')) {
    categories.push(currNode);
    currNode = currNode.nextElementSibling;
  }
  return categories;
}

