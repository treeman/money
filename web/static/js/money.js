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

document.getElementById("js_link").onclick = function() {
  console.log('Click!');
  get('budget/2016/7').then(function(response) {
    console.log("Success!", response);
  }, function(error) {
    console.error("Failed!", error);
  });
};

