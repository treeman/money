import MainView from '../main';
import {get, jsonReq} from "../request_helpers"
import * as view from "../view_helpers"

export default class View extends MainView {
  loaded() {
    super.loaded();

    initNav();
    initBudget();
  }

  unloaded() {
    super.unloaded();
  }

  handleKeyPress(e) {
    super.handleKeyPress(e);

    e = e || window.event;
    // Escape should cancel our current edit.
    if (e.keyCode == 27) {
      cancelCategoryInEdit();
    }
  }
}

function initNav() {
  initNewCategoryGroup();
  initDelete();
}

function initNewCategoryGroup() {
  var newForm = document.querySelector('form#create-category-group');
  newForm.addEventListener('submit', submitNewCategoryGroup);

  var addCategoryLink = document.querySelector('a.add-category-group');
  addCategoryLink.onclick = function() {
    // FIXME change text on link when changed
    if (newForm.classList.contains("hidden")) {
      newForm.classList.remove("hidden");
    } else {
      newForm.classList.add("hidden");
    }
  };
}

function initDelete() {
  var deleteForm = document.querySelector('form#delete-selected'); 
  deleteForm.addEventListener('submit', submitDeleteSelected);
}

function submitDeleteSelected(e) {
  e.preventDefault();
  var formData = new FormData(e.target);

  var checked = collectCheckedNames();
  formData.set("data[groups]", JSON.stringify(checked.groups));
  formData.set("data[categories]", JSON.stringify(checked.categories));

  jsonReq(e.target.action, formData, 200, true, 'DELETE').then(function(response) {
    // Ignore the return value here, should always be the checked ones.
    removeCheckedRows();
  }, function(error) {
    console.error("Failed!", error);
    view.setFlashError(error)
  });
}

function removeCheckedRows() {
  var rows = document.querySelectorAll('#budget .grid-body .grid-row');
  var deleteInGroup = false;
  for (var i = 0; i < rows.length; ++i) {
    var row = rows[i];

    var checked = row.querySelector('.grid-budget-cb input').checked;
    var isGroupRow = row.classList.contains("budgeted-group");
    if (isGroupRow) deleteInGroup = checked;
    if (checked || deleteInGroup) {
      row.remove();
    }
  }
}

function collectCheckedNames() {
  var rows = document.querySelectorAll('#budget .grid-body .grid-row');
  var groups = [];
  var categories = [];
  for (var i = 0; i < rows.length; ++i) {
    var row = rows[i];

    var cb = row.querySelector('.grid-budget-cb input');
    if (!cb.checked) continue;

    var name = row.querySelector('.grid-budget-category .name').innerHTML;

    if (row.classList.contains("budgeted-group")) {
      groups.push(name);
    } else {
      categories.push(name);
    }
  }
  return { groups: groups, categories: categories };
}

function submitNewCategoryGroup(e) {
  e.preventDefault();
  var formData = new FormData(e.target);

  jsonReq(e.target.action, formData, 201, true, 'POST').then(function(response) {
    var html = response.data.html_row;
    if (html) {
      // Create an element from the returned string.
      var row = document.createElement("div");
      row.innerHTML = html;
      row = row.firstChild;

      insertCategoryGroup(row);
    }
  }, function(error) {
    console.error("Failed!", error);
    view.setFlashError(error)
  });
}

function insertCategoryGroup(newRow) {
  var grid = document.querySelector('#budget .grid-body');
  var rows = grid.querySelectorAll('.grid-row.budgeted-group');
  var inserted = false;

  var newName = newRow.querySelector('.grid-budget-category .name').innerHTML;

  for (var i = 0; i < rows.length; ++i) {
    var row = rows[i];
    var name = row.querySelector('.grid-budget-category .name').innerHTML;
    if (newName < name) {
      row.parentNode.insertBefore(newRow, row);
      inserted = true;
      break;
    }
  }

  if (!inserted) {
    grid.appendChild(newRow);
  }
}

function initBudget() {
  var rows = document.querySelectorAll('#budget .grid-body .grid-row');
  for (var i = 0; i < rows.length; ++i) {
    initRow(rows[i]);
  }

  var newForm = document.querySelector('form#new-category');
  newForm.addEventListener('submit', submitNewCategory);
}

function initRow(row) {
  if (row.classList.contains("budgeted-group")) {
    initBudgetGroupRow(row);
  } else {
    initBudgetRow(row);
  }
}

function initBudgetGroupRow(row) {
  registerGroupOverEvent(row);
  registerArrowEvent(row);
  initGroupCB(row);
  registerNewCategoryEvent(row);
}

function registerGroupOverEvent(row) {
  var a = row.querySelector('.add-category');
  row.onmouseover = function() {
    a.classList.remove("hidden");
  }
  row.onmouseout = function() {
    a.classList.add("hidden");
  }
}

function initGroupCB(row) {
  var cb = row.querySelector('.grid-budget-cb input');

  cb.onclick = function(e) {
    propagateGroupSelect(row.nextElementSibling, cb.checked);
    updateBudgetInfo();
  }
}

function registerNewCategoryEvent(row) {
  var a = row.querySelector('.add-category');
  var group_id = row.querySelector('.grid-category-group-id').innerHTML;
  a.onclick = function() {
    console.log('new?');
    var newRow = createNewCategoryRow(group_id);
    row.parentNode.insertBefore(newRow, row.nextSibling);
  }
}

function createNewCategoryRow(group_id) {
  var row = document.createElement("div");
  row.setAttribute("class", "grid-row budgeted-category in-edit");
  row.innerHTML = "<div class=\"grid-cell grid-budget-cb\">\
  <input type=\"checkbox\">\
</div>\
<div class=\"grid-cell grid-budget-category\">\
  <input name=\"category[name]\">\
</div>\
<div class=\"grid-category-group-id\">\
  <input name=\"category[category_group_id]\" type=\"hidden\" value=\"" + group_id + "\">\
</div>\
<div class=\"grid-cell grid-budget-budgeted\">0</div>\
<div class=\"grid-cell grid-budget-activity\">0</div>\
<div class=\"grid-cell grid-budget-balance\">0</div>";

  var inputs = row.querySelectorAll('input');
  var form = document.querySelector('form#new-category');
  for (var i = 0; i < inputs.length; ++i) {
    inputs[i].setAttribute("form", form.id);
  }

  return row;
}

function cancelCategoryInEdit() {
  var formEditRows = document.querySelectorAll('.grid-row.budgeted-category.in-edit');
  for (var i = 0; i < formEditRows.length; ++i) {
    cancelEditRow(formEditRows[i]);
  }
}

function cancelEditRow(editRow) {
  var hiddenRow = editRow.nextSibling;
  if (hiddenRow.nodeType == Node.ELEMENT_NODE) {
    cancelEditCategory(hiddenRow, editRow);
  } else {
    cancelEditCategory(null, editRow);
  }
}

function cancelEditCategory(hiddenRow, editRow) {
  if (hiddenRow) {
    hiddenRow.style.display = editRow.style.display;
  }
  editRow.parentNode.removeChild(editRow);
}

function submitNewCategory(e) {
  e.preventDefault();

  var formData = new FormData(e.target);

  jsonReq(e.target.action, formData, 201, true, 'POST').then(function(response) {
    var html = response.data.html_row;
    if (html) {
      // Create an element from the returned string.
      var row = document.createElement("div");
      row.innerHTML = html;
      row = row.firstChild;

      // Insert and cancel edit for the row.
      var formEditRow = document.querySelector('.grid-row.budgeted-category.in-edit');
      var name = row.querySelector('.grid-budget-category .name').innerHTML;
      insertCategory(row, formEditRow.nextElementSibling, name);
      cancelEditRow(formEditRow);
    }
  }, function(error) {
    console.error("Failed!", error);
    view.setFlashError(error)
  });
}

function insertCategory(newRow, row, newName) {
  var name = row.querySelector('.grid-budget-category .name').innerHTML;
  if (newName < name || row.classList.contains("budgeted-group")) {
    row.parentNode.insertBefore(newRow, row);
  } else {
    insertCategory(newRow, row.nextElementSibling, newName);
  }
}

function propagateGroupSelect(row, checked) {
  if (row.classList.contains("budgeted-group")) return;
  var cb = row.querySelector('.grid-budget-cb input');
  cb.checked = checked;
  updateTransactionCBState(row, checked);
  propagateGroupSelect(row.nextElementSibling, checked);
}

function initBudgetRow(row) {
  initCategoryCB(row);
}

function initCategoryCB(row) {
  var cb = row.querySelector('.grid-budget-cb input');

  cb.onclick = function(e) {
    updateTransactionCBState(row, this.checked);
    updateBudgetInfo();
  }
}

function updateTransactionCBState(row, checked) {
  if (checked) {
    row.classList.add("checked");
  } else {
    row.classList.remove("checked");
  }
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
  var title = row.querySelector('.grid-budget-category .name').innerHTML;
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

