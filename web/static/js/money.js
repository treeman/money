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
function post(url, params) {
  // Use the new promise API
  return new Promise(function(resolve, reject) {
    var req = new XMLHttpRequest();
    req.open('POST', url);
    req.setRequestHeader("Content-type", "application/json; charset=utf-8");
    req.setRequestHeader("Content-length", params.length);
    req.setRequestHeader("Connection", "close");

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
    req.send(params);
  });
}

/*
document.getElementById("js_link").onclick = function() {
  console.log('Click!');

  //var params = JSON.stringify({ })
  get('/budget/2016/7').then(function(response) {
  //post('/accounts', params).then(function(response) {
    console.log("Success!", response);
  }, function(error) {
    console.error("Failed!", error);
  });
};
*/

/*
document.getElementById("").onclick = function() {
    console.log('Click!');
}
*/
/*
var table = document.getElementById("transactions");
console.log(table);
console.log(table.getElementsByClassName("tr"));
*/

// Changing edit functionality for all transactions.
var transaction_rows = document.querySelectorAll('#transactions tbody tr');
for (var i = 0; i < transaction_rows.length; ++i) {
    var row = transaction_rows[i];

    var edit = row.querySelectorAll('.btn-edit')[0];
    /*
    edit.onclick = function() {
        //console.log('Edit');
    }
    edit.setAttribute('href', '#');
    */
}

// Testing to add in a new transaction.
// TODO get info from server and then add in elements.
document.getElementById("js_link").onclick = function() {
    var x = document.getElementById("transactions");
    var body = x.getElementsByTagName("tbody")[0];
    var tr = body.getElementsByTagName("tr")[0];

    var newTransaction = document.createElement("tr");
    newTransaction.innerHTML = "\
        <td>9</td>\
        <td>2003-01-01</td>\
        <td>Mr. Robot</td>\
        <td>Series</td>\
        <td>Auto</td>\
        <td>-100</td>\
        <td>?</td>\
        <td class=\"text-right\">\
            <a class=\"btn btn-default btn-xs\" href=\"/transactions/1\">Show</a>\
            <a class=\"btn btn-default btn-xs\" href=\"/transactions/1/edit\">Edit</a>\
            <form class=\"link\" method=\"post\" action=\"/transactions/1\">\
                <input type=\"hidden\" value=\"delete\" name=\"_method\">\
                <input type=\"hidden\" value=\"ZHRdJCoTGQskXQE+K1BxRxMSKD4XAAAAP69HHzNHF45SB38uYElXQg==\" name=\"_csrf_token\">\
                <a class=\"btn btn-danger btn-xs\" rel=\"nofollow\" href=\"#\" data-submit=\"parent\" data-confirm=\"Are you sure?\">Delete</a>\
            </form>\
        </td>";

    tr.parentNode.insertBefore(newTransaction, tr.nextSibling);

    console.log(newTransaction);
};

