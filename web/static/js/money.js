/*
 * Constant changes.
 */
var newForm = document.querySelector('form#new-transaction');
var editForm = document.querySelector('form#edit-transaction');

var activeAccountId = document.querySelector('#active-account-id');
if (activeAccountId) activeAccountId = activeAccountId.innerHTML;

// Change edit and functionality for all transactions.
var transactionRows = document.querySelectorAll('#transactions .grid-body .grid-row');
for (var i = 0; i < transactionRows.length; ++i) {
    alterTransactionRow(transactionRows[i]);
}

// Awesomplete util for payees.
// FIXME do the same for categories.
var payeeDatalist = document.getElementById('transaction_payee-list');
var categoryDatalist = document.getElementById('transaction_category-list');

// Change add functionality for new transaction.
if (newForm) {
    newForm.addEventListener('submit', submitNewTransaction);
}

// Add transaction inside the transaction grid
var newTransaction = document.querySelector('#new-transaction-link');
if (newTransaction) {
    newTransaction.addEventListener('click', addNewTransaction);
}

document.onkeypress = function(evt) {
    evt = evt || window.event;
    // Escape should cancel our current edit.
    if (evt.keyCode == 27) {
        cancelTransactionInEdit();
    }
};

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
function addNewTransaction(evt) {
    evt.preventDefault();
    var row = createTransactionRowForm(newForm);
    var grid = document.querySelector('#transactions .grid-body');
    grid.insertBefore(row, grid.firstChild);

    if (activeAccountId) {
        var accountId = row.querySelector('.grid-account-id input');
        accountId.setAttribute("value", activeAccountId);
    }

    var dateInput = row.querySelector('.grid-transaction-date input');
    dateInput.setAttribute("value", currentDate());
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
}

function submitNewTransaction(evt) {
    console.log("submitting new transaction!?!?")
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
            alterTransactionRow(newTransaction);
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

function alterTransactionRow(row) {
    //alterEditButton(row);
    //alterDeleteButton(row);
    addEditAction(row);
}

function addEditAction(row) {
    row.ondblclick = function(evt) {
        evt.preventDefault();
        beginEditTransactionRow(row);
    }
}

/*
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
*/
function createTransactionRowForm(form) {
    var row = document.createElement("div");
    row.setAttribute("class", "grid-row transaction in-edit");
    row.innerHTML = "<div class=\"grid-cell grid-transaction-cb\">\
  <input type=\"checkbox\">\
</div>\
<div class=\"grid-account-id\">\
  <input name=\"transaction[account_id]\" type=\"hidden\">\
</div>\
<div class=\"grid-transaction-id\"></div>\
<div class=\"grid-cell grid-transaction-date\">\
  <input id=\"edit-transaction_when\" class=\"datepicker\" name=\"transaction[when]\" type=\"text\">\
</div>\
<div class=\"grid-cell grid-transaction-payee\">\
  <div class=\"awesomplete\">\
    <input id=\"edit-transaction_payee\" class=\"awesomplete\" name=\"transaction[payee]\" type=\"text\">\
  </div>\
</div>\
<div class=\"grid-cell grid-transaction-category\">\
  <div class=\"awesomplete\">\
    <input id=\"edit-transaction_category\" class=\"awesomplete\" name=\"transaction[category]\" type=\"text\">\
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
    var inputs = row.querySelectorAll('input');
    if (form) {
        for (var i = 0; i < inputs.length; ++i) {
            inputs[i].setAttribute("form", form.id);
        }
    }
    return row;

/*
<div class="grid-cell grid-transaction-cb">
<input type="checkbox">
</div>
<div class="grid-account-id">1</div>
<div class="grid-transaction-id">1</div>
<div class="grid-cell grid-transaction-date">2017-01-31</div>
<div class="grid-cell grid-transaction-payee">ASAD</div>
<div class="grid-cell grid-transaction-category">Rent</div>
<div class="grid-cell grid-transaction-description">asdfasd</div>
<div class="grid-cell grid-transaction-amount">999</div>
<div class="grid-cell grid-transaction-balance">11640</div>
<div class="grid-cell grid-transaction-cleared">
<a class="btn btn-default btn-xs" href="#">C</a>
</div>
*/
}

function beginEditTransactionRow(row) {
    var form = "edit-transaction";

    // Copy the row and modify it in place. Hide the old one for easy cancel.
    var editRow = document.createElement("div");
    editRow.setAttribute("class", "grid-row transaction in-edit");
    editRow.innerHTML = row.innerHTML;
    row.parentNode.insertBefore(editRow, row);
    row.style.display = 'none';

    var transaction = editRow.querySelector('.grid-transaction-id');
    var transaction_id = transaction.innerHTML;
    editForm.action = "/api/v1/transactions/" + transaction_id;

    var date = editRow.querySelector('.grid-transaction-date');
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

    var payee = editRow.querySelector('.grid-transaction-payee');
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
    AwesompleteUtil.start(payeeInput,
        { }, { minChars: 1, list: payeeDatalist }
    );

    var category = editRow.querySelector('.grid-transaction-category');
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

    var descr = editRow.querySelector('.grid-transaction-description');
    var descrInput = document.createElement("input");
    descrInput.setAttribute("form", form);
    descrInput.setAttribute("id", form + "_description");
    descrInput.setAttribute("name", "transaction[description]");
    descrInput.setAttribute("type", "text");
    descrInput.setAttribute("value", descr.innerHTML);
    descr.innerHTML = "";
    descr.appendChild(descrInput);

    var amount = editRow.querySelector('.grid-transaction-amount');
    var amountInput = document.createElement("input");
    amountInput.setAttribute("form", form);
    amountInput.setAttribute("id", form + "_amount");
    amountInput.setAttribute("name", "transaction[amount]");
    amountInput.setAttribute("type", "number");
    amountInput.setAttribute("step", "0.01");
    amountInput.setAttribute("value", amount.innerHTML);
    amount.innerHTML = "";
    amount.appendChild(amountInput);

    var buttons = editRow.querySelector('.grid-transaction-buttons');
    buttons.innerHTML = ""; // Kill em all! :)
    var save = document.createElement("input");
    save.setAttribute("class", "btn btn-default btn-xs save-edit");
    save.setAttribute("value", "Save");
    save.setAttribute("type", "submit");
    save.setAttribute("form", form);
    save.onclick = function(evt) {
        evt.preventDefault();
        saveEditTransaction(form, row, editRow);
    }
    buttons.appendChild(save);
    var cancel = document.createElement("input");
    cancel.setAttribute("class", "btn btn-default btn-xs cancel-edit");
    cancel.setAttribute("value", "Cancel");
    cancel.setAttribute("type", "submit");
    cancel.setAttribute("form", form);
    cancel.onclick = function(evt) {
        evt.preventDefault();
        cancelEditTransaction(row, editRow);
    }
    buttons.appendChild(cancel);
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

function saveEditTransaction(formId, hiddenRow, editRow) {
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
            alterTransactionRow(newTransaction);

            hiddenRow.parentNode.removeChild(editRow);
            hiddenRow.parentNode.removeChild(hiddenRow);
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
    var grid = document.querySelector('#transactions .grid-body');
    var rows = grid.querySelectorAll('.grid-row.transaction');
    var inserted = false;

    var newId = newRow.querySelector('.grid-transaction-id').innerHTML;
    var newDate = newRow.querySelector('.grid-transaction-date').innerHTML;

    for (var i = 0; i < rows.length; ++i) {
        var row = rows[i];
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

function updateAccountBalance(balances) {
    var grid = document.querySelector('#transactions .grid-body');
    var rows = grid.querySelectorAll('.grid-row.transaction');

    for (var i = 0; i < rows.length; ++i) {
        var row = rows[i];
        var id = row.querySelector('.grid-transaction-id').innerHTML;
        var newBalance = balances[id];
        if (newBalance) {
            var balance = row.querySelector('.grid-transaction-balance');
            balance.innerHTML = newBalance;
        }
    }
}

function currentDate() {
    var currentDate = new Date()
    var day = currentDate.getDate()
    var month = currentDate.getMonth() + 1
    var year = currentDate.getFullYear()
    return year + "-" + month + "-" + day;
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
                reject(formatJsonError(req.response, req.statusText));
            }
        };

        req.onerror = function() {
            reject(Error("Network Error"));
        };

        req.send(params);
    });
}

var humanErrors = new Map([
    ["amount", "Amount"],
    ["when", "Date"],
    ["payee", "Payee"],
    ["description", "Comment"],
    ["account_id", "Account"],
    ["category_id", "Category"]
]);

// Still not really suitable for humans. Need better js prevention
// and better css/html for the errors.
function formatJsonError(response, internalStatus) {
    var errors = response["errors"];
    if (errors) {
        var error = "";
        for (var key in errors) {
            var human = humanErrors.get(key);
            var descr = errors[key];
            if (humanErrors.has(key)) {
                error += human + " " + descr + "<br/>";
            } else {
                error += key + " " + descr + "<br/>";
            }
        }
        if (error) return error;
    }
    return internalStatus;
}

