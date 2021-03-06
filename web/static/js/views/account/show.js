import MainView from '../main';
import {get, jsonReq} from "../request_helpers"
import * as view from "../view_helpers"

// FIXME refactor the whole file...
// Globals during refactoring...
// Where to cache these?
var newForm;
var editForm;
var activeAccountId;

var payeeDatalist;
var categoryDatalist;
var accountDatalist;

export default class View extends MainView {
  loaded() {
    super.loaded();

    // FIXME move out functionality to functions
    newForm = document.querySelector('form#new-transaction');
    editForm = document.querySelector('form#edit-transaction');

    activeAccountId = document.querySelector('#active-account-id');
    if (activeAccountId) activeAccountId = activeAccountId.innerHTML;

    // Change edit and functionality for all transactions.
    // NOTE if performance issues arise, just cache all transaction rows.
    var transactionRows = document.querySelectorAll('#transactions .grid-body .grid-row');
    for (var i = 0; i < transactionRows.length; ++i) {
      alterTransactionRow(transactionRows[i]);
    }

    var transactionHeader = document.querySelector('#transactions .grid-header');
    if (transactionHeader) {
      alterTransactionHeader(transactionHeader);
    }

    var deleteTransactionsLink = document.querySelector("#delete-transactions input[type='submit']");
    if (deleteTransactionsLink) {
      alterDeleteTransactionsLink(deleteTransactionsLink);
    }

    // Lists for awesomplete
    payeeDatalist = document.getElementById('transaction_payee-list');
    categoryDatalist = document.getElementById('transaction_category-list');
    accountDatalist = document.getElementById('transaction_accounts-list');

    // Change add functionality for new transaction.
    if (newForm) {
      newForm.addEventListener('submit', submitNewTransaction);
    }

    // Add transaction inside the transaction grid
    var newTransaction = document.querySelector('#new-transaction-link');
    if (newTransaction) {
      newTransaction.addEventListener('click', addNewTransaction);
    }
  }

  unloaded() {
    super.unloaded();
  }

  handleKeyPress(e) {
    super.handleKeyPress(e);

    e = e || window.event;
    // Escape should cancel our current edit.
    if (e.keyCode == 27) {
      cancelTransactionInEdit();
    }
  }
}

function collectCheckedTransactions() {
  var rows = document.querySelectorAll('#transactions .grid-body .grid-row');
  var res = [];
  for (var i = 0; i < rows.length; ++i) {
    var row = rows[i];
    var cb = row.querySelector('.grid-transaction-cb input');
    if (cb.checked) {
      res.push(row);
    }
  }
  return res;
}

function collectCheckedTransactionIds() {
  var transactions = collectCheckedTransactions();
  var ids = [];
  for (var i = 0; i < transactions.length; ++i) {
    var row = transactions[i];
    var id = row.querySelector('.grid-transaction-id');
    ids.push(id.innerHTML);
  }
  return ids;
}

function updateAccountBalance(balances) {
  var grid = document.querySelector('#transactions .grid-body');
  var rows = grid.querySelectorAll('.grid-row.transaction');

  for (var i = 0; i < rows.length; ++i) {
    var row = rows[i];
    if (row.classList.contains("in-edit")) continue;
    var id = row.querySelector('.grid-transaction-id').innerHTML;
    var newBalance = balances[id];
    if (newBalance) {
      var balance = row.querySelector('.grid-transaction-balance');
      balance.innerHTML = newBalance;
    }
  }
}

function removeTransactionRows(ids) {
  var setIds = new Set();
  for (id of ids) {
    setIds.add(id);
  }
  var rows = document.querySelectorAll('#transactions .grid-body .grid-row');
  for (var i = 0; i < rows.length; ++i) {
    var row = rows[i];
    var id = row.querySelector('.grid-transaction-id').innerHTML;
    if (setIds.has(id)) {
      row.remove();
    }
  }
}

function addNewTransaction(evt) {
  evt.preventDefault();

  cancelTransactionInEdit();

  var row = createTransactionRowForm(newForm);
  var grid = document.querySelector('#transactions .grid-body');
  grid.insertBefore(row, grid.firstChild);

  if (!activeAccountId) {
    var accountInput = row.querySelector('.grid-account-title input');
    // FIXME find the latest submitted account somewhere.
    var account = accountDatalist.firstChild.innerHTML;
    accountInput.setAttribute("value", account);
  }

  var dateInput = row.querySelector('.grid-transaction-date input');
  dateInput.setAttribute("value", view.currentDate());
}

function submitNewTransaction(evt) {
  evt.preventDefault();
  var formData = new FormData(newForm);

  // FIXME validation on client side before we post.
  jsonReq(newForm.action, formData, 201, true, 'POST').then(function(response) {
    var html = response.data.html_row;
    if (html) {
      // Create an element from the returned string.
      var row = document.createElement("div");
      row.innerHTML = html;
      row = row.firstChild;

      insertTransaction(row);
      alterTransactionRow(row);
    }
    updateAccountBalance(response.data.transaction_balance)

    // Augment datalists.
    // FIXME awesomplete doesn't update. This is fruitless atm.
    /*
            var payeeDatalist = document.getElementById('transaction_payee-list');
            var newPayee = document.createElement("option");
            newPayee.innerHTML = response.data.payee;
            payeeDatalist.appendChild(newPayee);
            */
  }, function(error) {
    console.error("Failed!", error);
    view.setFlashError(error)
  });
}


function cancelTransactionInEdit() {
  var formEditRows = document.querySelectorAll('.grid-row.transaction.in-edit');
  for (var i = 0; i < formEditRows.length; ++i) {
    var editRow = formEditRows[i];
    var hiddenRow = editRow.nextSibling;
    if (hiddenRow.nodeType == Node.ELEMENT_NODE) {
      cancelEditTransaction(hiddenRow, editRow);
    } else {
      cancelEditTransaction(null, editRow);
    }
  }
}

function cancelEditTransaction(hiddenRow, editRow) {
  if (hiddenRow) {
    hiddenRow.style.display = editRow.style.display;
  }
  editRow.parentNode.removeChild(editRow);
}

function createTransactionRowForm(form) {
  var row = document.createElement("div");
  row.setAttribute("class", "grid-row transaction in-edit");
  row.innerHTML = "<div class=\"grid-cell grid-transaction-cb\">\
  <input type=\"checkbox\">\
</div>\
<div class=\"grid-cell grid-account-title\">\
  <div class=\"awesomplete\">\
    <input name=\"transaction[account]\">\
  </div>\
</div>\
<div class=\"grid-cell grid-transaction-date\">\
  <input id=\"edit-transaction_when\" class=\"datepicker\" name=\"transaction[when]\" type=\"text\">\
</div>\
<div class=\"grid-cell grid-transaction-payee\">\
  <div class=\"awesomplete\">\
    <input id=\"edit-transaction_payee\" name=\"transaction[payee]\" type=\"text\">\
  </div>\
</div>\
<div class=\"grid-cell grid-transaction-category\">\
  <div class=\"awesomplete\">\
    <input id=\"edit-transaction_category\" name=\"transaction[category]\" type=\"text\">\
  </div>\
</div>\
<div class=\"grid-cell grid-transaction-description\">\
  <input id=\"edit-transaction_description\" name=\"transaction[description]\" type=\"text\">\
</div>\
<div class=\"grid-cell grid-transaction-amount\">\
  <input id=\"edit-transaction_amount\" name=\"transaction[amount]\" step=\"0.01\" type=\"number\">\
</div>\
<div class=\"grid-cell grid-transaction-balance\"></div>\
<div class=\"grid-cell grid-transaction-cleared\">\
  <a class=\"btn btn-default btn-xs\" href=\"#\">C</a>\
</div>\
<div class=\"grid-transaction-buttons\">\
  <input type=\"submit\">submit</input>\
</div>";
  if (activeAccountId) {
    var accountGrid = row.querySelector('.grid-account-title');
    accountGrid.remove();
    var accountId = document.createElement("input");
    accountId.setAttribute("name", "transaction[account_id]");
    accountId.setAttribute("type", "hidden");
    accountId.setAttribute("value", activeAccountId);
    row.appendChild(accountId);
  } else {
    var accountInput = row.querySelector('.grid-account-title input');
    AwesompleteUtil.start(accountInput,
      { }, { minChars: 0, list: accountDatalist }
    );
  }

  var dateInput = row.querySelector('.grid-transaction-date input');
  var picker = new Pikaday({
    field: dateInput,
    firstDay: 1,
  });

  var payeeInput = row.querySelector('.grid-transaction-payee input');
  AwesompleteUtil.start(payeeInput,
    { }, { minChars: 1, list: payeeDatalist }
  );

  var categoryInput = row.querySelector('.grid-transaction-category input');
  AwesompleteUtil.start(categoryInput,
    { }, { minChars: 1, list: categoryDatalist }
  );

  var inputs = row.querySelectorAll('input');
  if (form) {
    for (var i = 0; i < inputs.length; ++i) {
      inputs[i].setAttribute("form", form.id);
    }
  }

  return row;
}

function alterTransactionHeader(header) {
  var cb = header.querySelector('.grid-transaction-cb input');

  cb.onclick = function(evt) {
    var cbs = document.querySelectorAll('#transactions .grid-body .grid-row .grid-transaction-cb input');
    for (var i = 0; i < cbs.length; ++i) {
      var cb = cbs[i];
      // Maybe hacky? :) Who cares...
      cb.checked = !this.checked;
      cb.click();
    }
  }
}

function alterTransactionRow(row) {
  addEditAction(row);
  alterCBAction(row);
}
function addEditAction(row) {
  row.ondblclick = function(evt) {
    evt.preventDefault();
    beginEditTransactionRow(row);
  }
}
function alterCBAction(row) {
  var cb = row.querySelector('.grid-transaction-cb input');
  updateTransactionCBState(row, cb.checked);

  cb.onclick = function(evt) {
    updateTransactionCBState(row, this.checked);
  }
}
function updateTransactionCBState(row, checked) {
  if (checked) {
    row.classList.add("checked");
  } else {
    row.classList.remove("checked");
  }
}

function alterDeleteTransactionsLink(link) {
  var form = link.parentNode;
  link.addEventListener('click', function(evt) {
    evt.preventDefault();
    if (window.confirm("Are you sure?")) {
      var ids = collectCheckedTransactionIds();
      var formData = new FormData(form);
      formData.set("data[ids]", JSON.stringify(ids));
      jsonReq(form.action, formData, 200, true, 'DELETE').then(function(response) {
        removeTransactionRows(ids);
        updateAccountBalance(response.data.transaction_balance);
      }, function(error) {
        console.error("Failed!", error);
        view.setFlashError(error)
      });
    }
  });
}

function beginEditTransactionRow(row) {
  cancelTransactionInEdit();

  var editRow = createTransactionRowForm(editForm);
  row.parentNode.insertBefore(editRow, row);
  row.style.display = 'none';

  var amount = row.querySelector('.grid-transaction-amount');
  var amountInput = editRow.querySelector('.grid-transaction-amount input');
  amountInput.setAttribute("value", amount.innerHTML);

  var transaction = row.querySelector('.grid-transaction-id');
  var transaction_id = transaction.innerHTML;
  editForm.action = "/api/v1/transactions/" + transaction_id;

  if (!activeAccountId) {
    var accountInput = editRow.querySelector('.grid-account-title input');
    var account = row.querySelector('.grid-account-title');
    accountInput.setAttribute("value", account.innerHTML);
  }

  var date = row.querySelector('.grid-transaction-date');
  var dateInput = editRow.querySelector('.grid-transaction-date input');
  dateInput.setAttribute("value", date.innerHTML);

  var payee = row.querySelector('.grid-transaction-payee');
  var payeeInput = editRow.querySelector('.grid-transaction-payee input');
  payeeInput.setAttribute("value", payee.innerHTML);

  var category = row.querySelector('.grid-transaction-category');
  var categoryInput = editRow.querySelector('.grid-transaction-category input');
  categoryInput.setAttribute("value", category.innerHTML);

  var descr = row.querySelector('.grid-transaction-description');
  var descrInput = editRow.querySelector('.grid-transaction-description input');
  descrInput.setAttribute("value", descr.innerHTML);

  var amount = row.querySelector('.grid-transaction-amount');
  var amountInput = editRow.querySelector('.grid-transaction-amount input');
  amountInput.setAttribute("value", amount.innerHTML);

  var submit = editRow.querySelector('.grid-transaction-buttons input');
  submit.onclick = function(evt) {
    evt.preventDefault();
    saveEditTransaction(row, editRow);
  }
}

function saveEditTransaction(hiddenRow, editRow) {
  var formData = new FormData(editForm);

  // FIXME validation on client side before we post.
  jsonReq(editForm.action, formData, 200, true, 'PUT').then(function(response) {
    var html = response.data.html_row;
    if (html) {
      // Create an element from the returned string.
      var newTransaction = document.createElement("div");
      newTransaction.innerHTML = html;
      newTransaction = newTransaction.firstChild;

      insertTransaction(newTransaction);
      alterTransactionRow(newTransaction);

      editRow.remove();
      hiddenRow.remove();
    }

    updateAccountBalance(response.data.transaction_balance)
  }, function(error) {
    console.error("Failed!", error);
    setFlashError(error);
  });
}

function comesBefore(aDate, aId, bDate, bId) {
  if (aDate > bDate) return true;
  if (aDate < bDate) return false;
  return aId > bId;
}

function insertTransaction(newRow) {
  var grid = document.querySelector('#transactions .grid-body');
  var rows = grid.querySelectorAll('.grid-row.transaction');
  var inserted = false;

  var newId = newRow.querySelector('.grid-transaction-id').innerHTML;
  var newDate = newRow.querySelector('.grid-transaction-date').innerHTML;

  for (var i = 0; i < rows.length; ++i) {
    var row = rows[i];
    if (row.classList.contains('in-edit')) continue;

    var id = row.querySelector('.grid-transaction-id').innerHTML;
    var date = row.querySelector('.grid-transaction-date').innerHTML;

    // FIXME Should allow for different kinds of sorting.
    if (comesBefore(newDate, newId, date, id)) {
      row.parentNode.insertBefore(newRow, row);
      inserted = true;
      break;
    }
  }

  if (!inserted) {
    grid.appendChild(newRow);
  }
}
