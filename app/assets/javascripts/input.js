// Capitalizes first letter of the string
function capitalize(input) {
    return input.charAt(0).toUpperCase() + input.slice(1);
}

// Chooses the transaction category when a user selects it
function selectCategory(element) {
  var color = element.dataset.color;
  var category = element.dataset.category;
  var icon = element.dataset.icon;

  var iconContainer = document.getElementsByClassName("category-icon-container")[0];
  var iconElement = document.getElementsByClassName("category-icon")[0];
  var categoryText = document.getElementsByClassName("category-data")[0];
  var inputBox = document.getElementById("category")

  iconContainer.style.backgroundColor = color;
  iconElement.className = "category-icon fa fa-" + icon;
  categoryText.innerHTML = capitalize(category);
  inputBox.value = category;

  document.getElementsByClassName("transaction-name-input")[0].focus();
  document.getElementsByClassName('transaction-category-table')[0].style.borderColor = "";

}

// Transaction category selection for when a keyboard shortcut is used
function selectCategoryByKey(key, click) {

  var key_order = [
    "q", "w", "e", "r", "t", "y", "u", "i",
    "a", "s", "d", "f", "g", "h", "j", "k",
    "z", "x", "c", "v", "b", "n", "m", ",",
  ]

  var category_order = [
    "dining",
    "clothing",
    "groceries",
    "automotive",
    "gifts",
    "entertainment",
    "recreation",
    "transit",
    "utilities",
    "services",
    "medical",
    "debt",
    "luxury",
    "education",
    "pets",
    "insurance",
    "supplies",
    "housing",
    "charity",
    "banking",
    "travel",
    "personal care",
    "electronics",
    "miscellaneous",
  ]

  var character = "";

  if (key === 188) {
    character = ",";
  } else if (key >= 65 && key <= 90) {
    character = String.fromCharCode(key + 32);
  } else {
    return;
  }

  var index = key_order.indexOf(character);
  if (index === -1) return;

  var element = document.getElementById("category-type-" + category_order[index]);

  if (click === "down") {
    lightenUp(element);
  } else {
    revertColor(element);
    selectCategory(element);
  }

}

// Takes any element and automatically lightens up its background color
function lightenUp(element) {
  var hex = element.dataset.color;
  var red = parseInt((hex[1] + hex[2]), 16);
  var blue = parseInt((hex[3] + hex[4]), 16);
  var green = parseInt((hex[5] + hex[6]), 16);

  var all = [red, blue, green];
  for (var i = 0; i < 3; i ++) {
    all[i] += 30;
    if (all[i] > 255) all[i] = 255;
    all[i] =  all[i].toString(16);
  }

  element.style.backgroundColor =  "#" + all[0] + all[1] + all[2];
}

// Returns an elements background color to its initial value
function revertColor(element) {
  element.style.backgroundColor = element.dataset.color;
}

// Number must between 8 or less digits
function isValidNum(amount) {
  if (amount.length > 8) return false;

  for (var i = 0; i < amount.length; i++) {
    if (amount[i] < "0" || amount[i] > "9") return false;
  }

  return true;
}

// Validates that the transaction dollar amount is a valid input
function validateAmount(key, input) {

  var amount = input.value;
  amount = amount.replace(/\./g, "");
  amount = amount.replace(/^0*/, "");
  var container = document.getElementsByClassName("transaction-icon-container")[0];
  var text = document.getElementsByClassName("amount-data")[0];

  if (amount.length === 0) {
    container.classList.remove("transaction-valid");
    container.classList.remove("transaction-invalid");
    input.value = "";
    text.innerHTML = "$0.00";
    return false;
  }

  valid = isValidNum(amount);

  if (key === 13 && valid) {
    document.getElementsByClassName("transaction-category-table")[0].focus();
    return true;
  }

  if (valid) {
    container.classList.remove("transaction-invalid");
    container.classList.add("transaction-valid");

    var decimal = (parseInt(amount) / 100).toFixed(2);
    input.value = decimal;
    text.innerHTML = "$" + decimal;

    return true;

  } else {
    container.classList.remove("transaction-valid");
    container.classList.add("transaction-invalid");
    text.innerHTML = "$0.00";

    return false;
  }

}

// Validates that the location name is a valid input
function validateDescription(key, input) {
  var location_name = input.value;

  var container = document.getElementsByClassName("transaction-icon-container")[1];
  var text = document.getElementsByClassName("location-data")[0];

  if (location_name.length === 0) {

    container.classList.remove("transaction-valid");
    container.classList.remove("transaction-invalid");
    text.innerHTML = "Location name";
    return false;

  } else if (location_name.length > 25) {

    container.classList.remove("transaction-valid");
    container.classList.add("transaction-invalid");
    text.innerHTML = "Location name";
    return false;

  } else {

    container.classList.remove("transaction-invalid");
    container.classList.add("transaction-valid");
    text.innerHTML = capitalize(location_name);

    if (key === 13) {
       document.getElementById('transaction-location-input').focus();
    }

    return true;

  }

}

// Validates all inputs before creating a new entry in the transaction table
function verifyTransaction() {
  var check = 7;
  var amountInput = document.getElementsByClassName("transaction-amount-input")[0];
  var categoryInput = document.getElementsByClassName("transaction-category-input")[0];
  var nameInput = document.getElementsByClassName("transaction-name-input")[0];
  var locationInput = document.getElementById("transaction-latitude-input");

  if (validateAmount(0, amountInput)) check -= 4;
  if (categoryInput.value.length > 0) check -= 2;
  if (validateDescription(0, nameInput) || locationInput.value.length > 1) check -= 1;

  if (check === 0) {
    return true;
  } else if (check >= 4) {
    amountInput.focus();
  } else if (check >= 2) {
    categoryInput.focus();
  } else {
    nameInput.focus();
  }

  return false;

}


// Validates that the transaction dollar amount is a valid input
function validateIncome(key, input) {

  var amount = input.value;
  amount = amount.replace(/\./g, "");
  amount = amount.replace(/^0*/, "");
  var container = document.getElementsByClassName("transaction-icon-container")[0];

  if (amount.length === 0) {
    container.classList.remove("transaction-valid");
    container.classList.remove("transaction-invalid");
    input.value = "";
    return false;
  }

  valid = isValidNum(amount);

  if (key === 13 && valid) {
    document.getElementsByClassName("transaction-name-input")[0].focus();
    return true;
  }

  if (valid) {
    container.classList.remove("transaction-invalid");
    container.classList.add("transaction-valid");

    var decimal = (parseInt(amount) / 100).toFixed(2);
    input.value = decimal;

    return true;

  } else {
    container.classList.remove("transaction-valid");
    container.classList.add("transaction-invalid");

    return false;
  }

}

// Validates that the location name is a valid input
function validateSource(key, input) {
  var location_name = input.value;

  var container = document.getElementsByClassName("transaction-icon-container")[1];

  if (location_name.length === 0) {

    container.classList.remove("transaction-valid");
    container.classList.remove("transaction-invalid");
    return false;

  } else if (location_name.length > 25) {

    container.classList.remove("transaction-valid");
    container.classList.add("transaction-invalid");
    return false;

  } else {

    container.classList.remove("transaction-invalid");
    container.classList.add("transaction-valid");

    if (key === 13) {
       document.getElementById('income-form').submit();
    }

    return true;

  }

}


// Validates all inputs before creating a new entry in the income table.
function verifyIncome() {
  var check = 3;
  var incomeInput = document.getElementsByClassName("transaction-amount-input")[0];
  var sourceInput = document.getElementsByClassName("transaction-name-input")[0];
  alert(check);
  if (validateIncome(0, incomeInput)) check -= 2;
  alert(check);
  if (validateSource(0, sourceInput)) check -= 1;
  alert(check);
  if (check === 0) {
    return true;
  } else if (check >= 3) {
    incomeInput.focus();
  } else {
    sourceInput.focus();
  }
  alert("hey");
  return false;

}
