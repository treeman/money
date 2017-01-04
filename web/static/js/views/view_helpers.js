export function setFlashInfo(text) {
    var p = document.querySelectorAll('.alert.alert-info')[0];
    p.innerHTML = text;
}
export function setFlashError(text) {
    var p = document.querySelectorAll('.alert.alert-danger')[0];
    p.innerHTML = text;
}

export function currentDate() {
    var currentDate = new Date()
    var day = currentDate.getDate()
    if (day < 10) day = "0" + day;
    var month = currentDate.getMonth() + 1
    if (month < 10) month = "0" + month;
    var year = currentDate.getFullYear()
    return year + "-" + month + "-" + day;
}

