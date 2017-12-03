function verify_edit(username) {
  var check = 4;

  if (validateExisting(document.getElementById("entry-input-username"), username)) check--;
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

// Validate the input 1 second after the user has finished typing
function delayedValidateExisting(item, username) {
  delay(function() {
    validateExisting(item, username);
  }, 1000)
}

// Validate a username in the edit account page
function validateExisting(item, username) {

  input = item.value;

  // When there is no input, make the input box the default gray
  if (input.length === 0) {
    item.parentNode.childNodes[1].className = "entry-icon-container";
    return;
  }

  if (document.getElementById("entry-input-username").value === username) {
    validInput = true;
  } else {
    validInput = validateUsername(input);
  }

  // Makes the input box green or red depending on if the input is valid
  if (validInput) {
    item.parentNode.childNodes[1].className = "entry-icon-container entry-valid";
  } else {
    item.parentNode.childNodes[1].className = "entry-icon-container entry-invalid";
  }

}
