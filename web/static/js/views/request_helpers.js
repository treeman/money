/*
 * Ajax with promises.
 * See http://www.html5rocks.com/en/tutorials/es6/promises/
 */
export function get(url) {
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

export function jsonReq(url, params, successStatus = 200, binary = false, type = 'POST') {
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

