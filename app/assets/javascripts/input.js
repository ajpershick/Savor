function capitalize(input) {
    return input.charAt(0).toUpperCase() + input.slice(1);
}

function selectCategory(element) {
  var color = element.dataset.color;
  var category = element.dataset.category;
  var icon = element.dataset.icon;

  var iconContainer = document.getElementsByClassName("category-icon-container")[0];
  var iconElement = document.getElementsByClassName("category-icon")[0];
  var categoryText = document.getElementsByClassName("category-data")[0];

  iconContainer.style.backgroundColor = color;
  iconElement.className = "category-icon fa fa-" + icon;
  categoryText.innerHTML = capitalize(category);

  document.getElementsByClassName("transaction-name-input")[0].focus();
  document.getElementsByClassName('transaction-category-table')[0].style.borderColor = "";

}

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
    "maintenance",
    "medical",
    "debt",
    "luxury",
    "education",
    "pets",
    "insurance",
    "supplies",
    "housing",
    "charity",
    "savings",
    "travel",
    "personal care",
    "taxes",
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
    return;
  }

  valid = isValidNum(amount);

  if (key === 13 && valid) {
    document.getElementsByClassName("transaction-category-table")[0].focus();
    return;
  }

  if (valid) {
    container.classList.remove("transaction-invalid");
    container.classList.add("transaction-valid");

    var decimal = (parseInt(amount) / 100).toFixed(2);
    input.value = String(decimal);
    text.innerHTML = String(decimal);

  } else {
    container.classList.remove("transaction-valid");
    container.classList.add("transaction-invalid");
    text.innerHTML = "$0.00";
  }

}

// Validates that the location name is a valid input
function validateLocationName(key, input) {
  var location_name = input.value;

  var container = document.getElementsByClassName("transaction-icon-container")[1];
  var text = document.getElementsByClassName("location-data")[0];

  if (location_name.length === 0) {

    container.classList.remove("transaction-valid");
    container.classList.remove("transaction-invalid");
    text.innerHTML = "Location name";

  } else if (location_name.length > 25) {

    container.classList.remove("transaction-valid");
    container.classList.add("transaction-invalid");
    text.innerHTML = "Location name";

  } else {

    container.classList.remove("transaction-invalid");
    container.classList.add("transaction-valid");
    text.innerHTML = capitalize(location_name);

  }

}
