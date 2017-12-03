function verify_edit(username) {
  var check = 4;

  if (
    validateInput(document.getElementById("entry-input-username"), "username") ||
    document.getElementById("entry-input-username").value === username
  ) check--;
  if (validateInput(document.getElementById("entry-input-name"), "name")) check--;
  if (validateInput(document.getElementById("entry-input-email"), "email")) check--;
  if (validateInput(document.getElementById("entry-input-password"), "password")) check--;

  if (check == 0) {

    return true;

  } else {

    var invalid_inputs = document.getElementsByClassName("entry-invalid");
    var errors = [];

    for (var i = 0; i < invalid_inputs.length; i++) {
      errors[i] = invalid_inputs[i].childNodes[1];
    }

    for (var i = 0; i < errors.length; i++) {
      errors[i].classList.remove("entry-tooltip-temporary");
      errors[i].classList.add("entry-tooltip-temporary");
    }

    delay(function() {
      for (var i = 0; i < errors.length; i++) {
        errors[i].classList.remove("entry-tooltip-temporary");
      }
    }, 1500);

    return false;
  }
}
