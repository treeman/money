import MainView from '../main';
import {get, jsonReq} from "../request_helpers"
import * as view from "../view_helpers"

export default class View extends MainView {
  loaded() {
    super.loaded();

    initBudget();
    initBudgetInfo();
  }

  unloaded() {
    super.unloaded();
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

function initBudget() {
  var rows = document.querySelectorAll('#budget .grid-body .grid-row');
  for (var i = 0; i < rows.length; ++i) {
    initRow(rows[i]);
  }
}

function initRow(row) {
  if (row.classList.contains("budgeted-group")) {
    initBudgetGroupRow(row);
  } else {
    initBudgetRow(row);
  }
}

function initBudgetGroupRow(row) {
  registerArrowEvent(row);
}

function initBudgetRow(row) {
  initCB(row);
}

function initCB(row) {
  var cb = row.querySelector('.grid-budget-cb input');

  cb.onclick = function(evt) {
    updateTransactionCBState(row, this.checked);
  }
}

function initBudgetInfo() {
  var edit = document.querySelector('#budget-info a.delete-category');
  edit.onclick = function(e) {
    console.log('click');
  }

  // FIXME not sure if we should have an edit or just a delete?
  // Delete is probably better.
  /*
  var edit = document.querySelector('#budget-info a.edit-category');
  console.log(edit);
  edit.onclick = function(e) {
    console.log('click');
  }
  */
}

function updateTransactionCBState(row, checked) {
  if (checked) {
    row.classList.add("checked");
  } else {
    row.classList.remove("checked");
  }
  updateBudgetInfo();
}

function updateBudgetInfo() {
  var checkedRows = collectCheckedCategories();
  if (checkedRows.length > 1) {
    showMultipleBudgetInfo(checkedRows);
  } else if (checkedRows.length == 1) {
    showSingleBudgetInfo(checkedRows[0]);
  } else {
    showDefaultBudgetInfo();
  }
}

function showMultipleBudgetInfo(rows) {
  console.log('Show combined info');
  console.log(rows);
}

function showSingleBudgetInfo(row) {
  console.log('Show info for a single category');
  console.log(row);

  var title = row.querySelector('.grid-budget-category').innerHTML;
  var budgeted = row.querySelector('.grid-budget-budgeted').innerHTML;
  var activity = row.querySelector('.grid-budget-activity').innerHTML;
  var balance = row.querySelector('.grid-budget-balance').innerHTML;

  var budgetInfo = document.querySelector('#budget-info');
  var titleDiv = budgetInfo.querySelector('.category .name');
  titleDiv.innerHTML = title;
  var budgetedDiv = budgetInfo.querySelector('.money-row.budgeted-this-month .amount');
  budgetedDiv.innerHTML = budgeted;
  var spendingDiv = budgetInfo.querySelector('.money-row.spending .amount');
  spendingDiv.innerHTML = activity;
  var availableDiv = budgetInfo.querySelector('.available-money .amount');
  availableDiv.innerHTML = balance;
}

function showDefaultBudgetInfo() {
  console.log('Show default info');
}


function collectCheckedCategories() {
  var rows = document.querySelectorAll('#budget .grid-body .grid-row.budgeted-category');
  var res = [];
  for (var i = 0; i < rows.length; ++i) {
    var row = rows[i];
    var cb = row.querySelector('.grid-budget-cb input');
    if (cb.checked) {
      res.push(row);
    }
  }
  return res;
}


function registerArrowEvent(row) {
  var div = row.querySelector('.grid-budget-arrow');
  div.addEventListener('click', toggleGroupExpand);
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

