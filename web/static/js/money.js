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

    var edit = row.querySelectorAll('.btn-edit')[0];
    /*
    edit.onclick = function() {
        console.log('Edit');
    }
    edit.setAttribute('href', '#');
    */
}

function comes_before(a_date, a_id, b_date, b_id) {
    if (a_date > b_date) return true;
    if (a_date < b_date) return false;
    return a_id > b_id;
}

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
        }, function(error) {
            // FIXME add in flash.
            console.error("Failed!", error);
            set_flash_error(error)
        });
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

