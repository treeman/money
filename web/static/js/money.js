/*
 * Constant changes.
 */
var newForm = document.querySelector('form#new-transaction');
var editForm = document.querySelector('form#edit-transaction');

// Change edit and functionality for all transactions.
var transactionRows = document.querySelectorAll('#transactions .tbody .tr');
for (var i = 0; i < transactionRows.length; ++i) {
    var row = transactionRows[i];
    alterEditButton(row);
    alterDeleteButton(row);
}

// Awesomplete util for payees.
// FIXME do the same for categories.
var payeeDatalist = document.getElementById('transaction_payee-list');
AwesompleteUtil.start('#new-transaction-payee',
    { }, { minChars: 1, list: payeeDatalist }
);

// Change add functionality for new transaction.
if (newForm) {
    newForm.addEventListener('submit', submitNewTransaction);
}

var datepickers = document.querySelectorAll('.datepicker');
for (var i = 0; i < datepickers.length; ++i) {
    // Date picking for new transaction.
    var picker = new Pikaday({
        field: datepickers[i],
        firstDay: 1,
        //minDate: new Date(),
        //maxDate: new Date(2020, 12, 31),
        //yearRange: [2000,2020]
    });
}


/*
 * Impl.
 */
function submitNewTransaction(evt) {
    evt.preventDefault();
    var formData = new FormData(newForm);

    // FIXME validation on client side before we post.
    jsonReq(newForm.action, formData, 201, true, 'POST').then(function(response) {
        var html = response.data.html_row;
        if (html) {
            // Create an element from the returned string.
            var newTransaction = document.createElement("div");
            newTransaction.innerHTML = html;
            newTransaction = newTransaction.firstChild;

            insertTransaction(newTransaction);
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
        setFlashError(error)
    });
}

function alterEditButton(row) {
    var edit = row.querySelectorAll('.btn-edit')[0];
    if (edit) {
        edit.onclick = function() {
            beginEditTransactionRow(row);
        }
        edit.setAttribute('href', '#');
    }
}

function alterDeleteButton(row) {
    var transaction = row.querySelector('.transaction-id');
    var transaction_id = transaction.innerHTML;

    var buttons = row.querySelector('.transaction-buttons');

    var form = buttons.querySelector('form');
    form.action = "/api/v1/transactions/" + transaction_id;

    // Workaround data-submit, phoenix default uses some js here.
    var btn = buttons.querySelector('.btn-danger');
    btn.addEventListener('click', function(evt) {
        evt.preventDefault();
        if (window.confirm("Are you sure?")) {
            var formData = new FormData(form);
            jsonReq(form.action, formData, 200, true, 'DELETE').then(function(response) {
                row.parentNode.removeChild(row);
                updateAccountBalance(response.data.transaction_balance)
            }, function(error) {
                console.error("Failed!", error);
                setFlashError(error)
            });
        }
    });
    btn.removeAttribute("data-submit");
}

function beginEditTransactionRow(row) {
    console.log('edit', row);
    var form = "edit-transaction";

    // Copy the row and modify it in place. Hide the old one for easy cancel.
    var newRow = document.createElement("div");
    newRow.setAttribute("class", "tr transaction");
    newRow.innerHTML = row.innerHTML;
    row.parentNode.insertBefore(newRow, row);
    row.style.display = 'none';

    var transaction = newRow.querySelector('.transaction-id');
    var transaction_id = transaction.innerHTML;
    editForm.action = "/api/v1/transactions/" + transaction_id;

    var date = newRow.querySelector('.transaction-date');
    var dateInput = document.createElement("input");
    dateInput.setAttribute("form", form);
    dateInput.setAttribute("id", form + "_when");
    dateInput.setAttribute("name", "transaction[when]");
    dateInput.setAttribute("type", "text");
    dateInput.setAttribute("class", "datepicker");
    dateInput.setAttribute("value", date.innerHTML);
    date.innerHTML = "";
    date.appendChild(dateInput);
    var picker = new Pikaday({
        field: dateInput,
        firstDay: 1,
    });

    var payee = newRow.querySelector('.transaction-payee');
    var payeeInput = document.createElement("input");
    payeeInput.setAttribute("form", form);
    payeeInput.setAttribute("id", form + "_payee");
    payeeInput.setAttribute("name", "transaction[payee]");
    payeeInput.setAttribute("type", "text");
    payeeInput.setAttribute("class", "awesomplete");
    payeeInput.setAttribute("value", payee.innerHTML);
    var awesompleteDiv = document.createElement("div");
    awesompleteDiv.setAttribute("class", "awesomplete");
    awesompleteDiv.appendChild(payeeInput);
    payee.innerHTML = "";
    payee.appendChild(awesompleteDiv);
    AwesompleteUtil.start('#' + form + '_payee',
        { }, { minChars: 1, list: payeeDatalist }
    );

    var category = newRow.querySelector('.transaction-category');
    var categoryInput = document.createElement("input");
    categoryInput.setAttribute("form", form);
    categoryInput.setAttribute("id", form + "_category");
    categoryInput.setAttribute("name", "transaction[category]");
    categoryInput.setAttribute("type", "text");
    categoryInput.setAttribute("class", "awesomplete");
    categoryInput.setAttribute("value", category.innerHTML);
    var awesompleteDiv = document.createElement("div");
    awesompleteDiv.setAttribute("class", "awesomplete");
    awesompleteDiv.appendChild(categoryInput);
    category.innerHTML = "";
    category.appendChild(awesompleteDiv);
    AwesompleteUtil.start('#' + form + '_category',
        { }, { minChars: 1, list: document.getElementById('transaction_category-list') }
    );

    var descr = newRow.querySelector('.transaction-description');
    var descrInput = document.createElement("input");
    descrInput.setAttribute("form", form);
    descrInput.setAttribute("id", form + "_description");
    descrInput.setAttribute("name", "transaction[description]");
    descrInput.setAttribute("type", "text");
    descrInput.setAttribute("value", descr.innerHTML);
    descr.innerHTML = "";
    descr.appendChild(descrInput);

    var amount = newRow.querySelector('.transaction-amount');
    var amountInput = document.createElement("input");
    amountInput.setAttribute("form", form);
    amountInput.setAttribute("id", form + "_amount");
    amountInput.setAttribute("name", "transaction[amount]");
    amountInput.setAttribute("type", "number");
    amountInput.setAttribute("step", "0.01");
    amountInput.setAttribute("value", amount.innerHTML);
    amount.innerHTML = "";
    amount.appendChild(amountInput);

    var buttons = newRow.querySelector('.transaction-buttons');
    buttons.innerHTML = ""; // Kill em all! :)
    var save = document.createElement("input");
    save.setAttribute("class", "btn btn-default btn-xs save-edit");
    save.setAttribute("value", "Save");
    save.setAttribute("type", "submit");
    save.setAttribute("form", form);
    save.onclick = function(evt) {
        evt.preventDefault();
        saveEditTransaction(form, row, newRow);
    }
    buttons.appendChild(save);
    var cancel = document.createElement("input");
    cancel.setAttribute("class", "btn btn-default btn-xs cancel-edit");
    cancel.setAttribute("value", "Cancel");
    cancel.setAttribute("type", "submit");
    cancel.setAttribute("form", form);
    cancel.onclick = function(evt) {
        evt.preventDefault();
        cancelEditTransaction(row, newRow);
    }
    buttons.appendChild(cancel);
}

function cancelEditTransaction(row, newRow) {
    row.style.display = newRow.style.display;
    newRow.parentNode.removeChild(newRow);
}

function saveEditTransaction(formId, row, newRow) {
    var editForm = document.querySelector('form#' + formId);
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
            row.parentNode.removeChild(newRow);
            row.parentNode.removeChild(row);
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


function setFlashInfo(text) {
    var p = document.querySelectorAll('.alert.alert-info')[0];
    p.innerHTML = text;
}
function setFlashError(text) {
    var p = document.querySelectorAll('.alert.alert-danger')[0];
    p.innerHTML = text;
}

function insertTransaction(newRow) {
    var table = document.querySelector('#transactions .tbody');
    var rows = table.querySelectorAll('.tr.transaction');
    var inserted = false;

    var newId = newRow.querySelector('.transaction-id').innerHTML;
    var newDate = newRow.querySelector('.transaction-date').innerHTML;

    for (var i = 0; i < rows.length; ++i) {
        var row = rows[i];
        var id = row.querySelector('.transaction-id').innerHTML;
        var date = row.querySelector('.transaction-date').innerHTML;

        // FIXME Should allow for different kinds of sorting.
        if (comesBefore(newDate, newId, date, id)) {
            row.parentNode.insertBefore(newRow, row);
            inserted = true;
            break;
        }
    }

    if (!inserted) {
        table.appendChild(newRow);
    }
}

function updateAccountBalance(balances) {
    var table = document.querySelector('#transactions .tbody');
    var rows = table.querySelectorAll('.tr.transaction');

    for (var i = 0; i < rows.length; ++i) {
        var row = rows[i];
        var id = row.querySelector('.transaction-id').innerHTML;
        var newBalance = balances[id];
        if (newBalance) {
            var balance = row.querySelector('.transaction-balance');
            balance.innerHTML = newBalance;
        }
    }
}

/*
 * Ajax with promises.
 * See http://www.html5rocks.com/en/tutorials/es6/promises/
 */
function get(url) {
  return new Promise(function(resolve, reject) {
    var req = new XMLHttpRequest();
    req.open('GET', url);

    req.onload = function() {
      if (req.status == 200) {
        resolve(req.response)
      } else {
        reject(Error(req.statusText));
      }
    };

    req.onerror = function() {
      reject(Error("Network Error"));
    };

    req.send();
  });
}

function jsonReq(url, params, successStatus = 200, binary = false, type = 'POST') {
  return new Promise(function(resolve, reject) {
    var req = new XMLHttpRequest();
    req.open(type, url);
    if (!binary) {
        req.setRequestHeader("Content-type", "application/json; charset=utf-8");
        req.setRequestHeader("Content-length", params.length);
        req.setRequestHeader("Connection", "close");
    }
    req.responseType = "json";

    req.onload = function() {
      if (req.status == successStatus) {
        resolve(req.response)
      } else {
        // FIXME do something smarter here perhaps...?
        reject(Error(req.statusText));
        //console.log(req.statusText);
        //reject(req.response);
      }
    };

    req.onerror = function() {
      reject(Error("Network Error"));
    };

    req.send(params);
  });
}

