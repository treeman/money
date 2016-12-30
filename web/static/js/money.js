// See http://www.html5rocks.com/en/tutorials/es6/promises/
function get(url) {
  // Use the new promise API
  return new Promise(function(resolve, reject) {
    var req = new XMLHttpRequest();
    req.open('GET', url);

    req.onload = function() {
      // This is always called
      if (req.status == 200) {
        // Resolve with response text
        resolve(req.response)
      } else {
        // Otherwise reject with the status text
        reject(Error(req.statusText));
      }
    };

    // Handle network errors
    req.onerror = function() {
      reject(Error("Network Error"));
    };

    // Make the request
    req.send();
  });
}

// See http://www.html5rocks.com/en/tutorials/es6/promises/
function post(url, params, success_status = 200, binary = false) {
  // Use the new promise API
  return new Promise(function(resolve, reject) {
    var req = new XMLHttpRequest();
    req.open('POST', url);
    if (!binary) {
        req.setRequestHeader("Content-type", "application/json; charset=utf-8");
        req.setRequestHeader("Content-length", params.length);
        req.setRequestHeader("Connection", "close");
    }
    req.responseType = "json";

    req.onload = function() {
      // This is always called
      if (req.status == success_status) {
        // Resolve with response text
        resolve(req.response)
      } else {
        // Otherwise reject with the status text
        // FIXME do something smarter here perhaps...?
        reject(Error(req.statusText));
        //console.log(req.statusText);
        //reject(req.response);
      }
    };

    // Handle network errors
    req.onerror = function() {
      reject(Error("Network Error"));
    };

    // Make the request
    req.send(params);
  });
}

// Changing edit functionality for all transactions.
var transaction_rows = document.querySelectorAll('#transactions .tbody .tr');
for (var i = 0; i < transaction_rows.length; ++i) {
    var row = transaction_rows[i];
    alter_edit_button(row);
}

function alter_edit_button(row) {
    var edit = row.querySelectorAll('.btn-edit')[0];
    if (edit) {
        edit.onclick = function() {
            begin_edit_transaction_row(row);
        }
        edit.setAttribute('href', '#');
    }
}

function begin_edit_transaction_row(row) {
    console.log('edit', row);
    var form = "edit_transaction";

    var date = row.querySelector('.transaction-date');
    var dateInput = document.createElement("input");
    dateInput.setAttribute("form", form);
    dateInput.setAttribute("id", form + "_when");
    dateInput.setAttribute("name", form + "[when]");
    dateInput.setAttribute("type", "text");
    dateInput.setAttribute("class", "datepicker");
    dateInput.setAttribute("value", date.innerHTML);
    date.innerHTML = "";
    date.appendChild(dateInput);
    var picker = new Pikaday({
        field: dateInput,
        firstDay: 1,
    });

    var payee = row.querySelector('.transaction-payee');
    var payeeInput = document.createElement("input");
    payeeInput.setAttribute("form", form);
    payeeInput.setAttribute("id", form + "_payee");
    payeeInput.setAttribute("name", form + "[payee]");
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

    var category = row.querySelector('.transaction-category');
    var categoryInput = document.createElement("input");
    categoryInput.setAttribute("form", form);
    categoryInput.setAttribute("id", form + "_category");
    categoryInput.setAttribute("name", form + "[category]");
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

    var descr = row.querySelector('.transaction-description');
    var descrInput = document.createElement("input");
    descrInput.setAttribute("form", form);
    descrInput.setAttribute("id", form + "_description");
    descrInput.setAttribute("name", form + "[description]");
    descrInput.setAttribute("type", "text");
    descrInput.setAttribute("value", descr.innerHTML);
    descr.innerHTML = "";
    descr.appendChild(descrInput);

    var amount = row.querySelector('.transaction-amount');
    var amountInput = document.createElement("input");
    amountInput.setAttribute("form", form);
    amountInput.setAttribute("id", form + "_amount");
    amountInput.setAttribute("name", form + "[amount]");
    amountInput.setAttribute("type", "number");
    amountInput.setAttribute("step", "0.01");
    amountInput.setAttribute("value", amount.innerHTML);
    amount.innerHTML = "";
    amount.appendChild(amountInput);

    // Hide all existing children and then insert a new button.
    var buttons = row.querySelector('.transaction-buttons');
    var buttonChildren = buttons.childNodes;
    for (var i = 0; i < buttonChildren.length; ++i) {
        var child = buttonChildren[i];
        if (child.style) {
            child.style.display = 'none';
            console.log(child);
        }
    }
    var save = document.createElement("input");
    save.setAttribute("class", "btn btn-default btn-xs save-edit");
    save.setAttribute("value", "Save");
    save.setAttribute("type", "submit");
    save.setAttribute("form", form);
    buttons.appendChild(save);
    var abort = document.createElement("input");
    abort.setAttribute("class", "btn btn-default btn-xs abort-edit");
    abort.setAttribute("value", "Abort");
    abort.setAttribute("type", "submit");
    abort.setAttribute("form", form);
    buttons.appendChild(abort);
}

function comes_before(a_date, a_id, b_date, b_id) {
    if (a_date > b_date) return true;
    if (a_date < b_date) return false;
    return a_id > b_id;
}

// Awesomplete util for payees.
// FIXME do the same for categories.
var payeeDatalist = document.getElementById('transaction_payee-list');
AwesompleteUtil.start('#new-transaction-payee',
    { }, { minChars: 1, list: payeeDatalist }
);

// Change add functionality for new transaction.
var new_form = document.querySelector('form#new-transaction');
if (new_form) {
    new_form.addEventListener('submit', function(evt) {
        evt.preventDefault();
        var formData = new FormData(new_form);

        // FIXME validation on client side before we post.
        post(new_form.action, formData, 201, true).then(function(response) {
            var html = response.data.html_row;
            if (html) {
                // Create an element from the returned string.
                var newTransaction = document.createElement("div");
                newTransaction.innerHTML = html;
                newTransaction = newTransaction.firstChild;

                // FIXME maybe in the future use a sorting routine and just insert this somewhere.
                // Should allow for different kinds of sorting.
                var newId = response.data.id;
                var newDate = response.data.when;

                var table = document.querySelector('#transactions .tbody');
                var rows = table.querySelectorAll('.tr.transaction');
                var inserted = false;
                for (var i = 0; i < rows.length; ++i) {
                    var row = rows[i];
                    //console.log(row);
                    var id = row.querySelector('.transaction-id');
                    var date = row.querySelector('.date');
                    if (id && date) {
                        id = id.innerHTML;
                        date = date.innerHTML;

                        if (comes_before(newDate, newId, date, id)) {
                            row.parentNode.insertBefore(newTransaction, row);
                            inserted = true;
                            break;
                        }
                    }
                }

                if (!inserted) {
                    table.appendChild(newTransaction);
                }
            }

            // Augment datalists.
            // awesomplete doesn't update. This is fruitless atm.
            //var payeeDatalist = document.getElementById('transaction_payee-list');
            /*
            var newPayee = document.createElement("option");
            newPayee.innerHTML = response.data.payee;
            payeeDatalist.appendChild(newPayee);
            */

            /*
            var categoryDatalist = document.querySelector('#transaction_category-list');
            var newCategory = document.createElement("option");
            newCategory.innerHTML = response.data.category;
            categoryDatalist.appendChild(newCategory);
            */
        }, function(error) {
            // FIXME add in flash.
            console.error("Failed!", error);
            set_flash_error(error)
        });
    });
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


function set_flash_info(text) {
    var p = document.querySelectorAll('.alert.alert-info')[0];
    p.innerHTML = text;
}
function set_flash_error(text) {
    var p = document.querySelectorAll('.alert.alert-danger')[0];
    p.innerHTML = text;
}

