function verify_edit(username) {
  var check = 4;

  if (validateExisting(document.getElementById("entry-input-username"), username)) check--;
  if (validateInput(document.getElementById("entry-input-name"), "name")) check--;
  if (validateInput(document.getElementById("entry-input-email"), "email")) check--;
  if (validateInput(document.getElementById("entry-input-password"), "password")) check--;

  if (check == 0) {
    return true;

  } else {

    showTooltips();
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
    return false;
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

  return validInput;
}



function verify_password() {
  var check = 3;

  if (validateInput(document.getElementById("entry-input-current-password"), "password")) check--;
  if (validateInput(document.getElementById("entry-input-password"), "password")) check--;
  if (validateInput(document.getElementById("entry-input-confirm-password"), "confirm-password")) check--;

  if (check == 0) {

    return true;

  } else {

    showTooltips();
    return false;

  }
}
