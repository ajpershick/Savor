// Takes any element and automatically lightens up its background color
function lightenUp(element) {
  hex = element.dataset.color;
  red = parseInt((hex[1] + hex[2]), 16);
  blue = parseInt((hex[3] + hex[4]), 16);
  green = parseInt((hex[5] + hex[6]), 16);

  all = [red, blue, green];
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


function validateAmount(key, input) {
  if (key === 14) {

  }

  amount = input.value;
  amount = amount.replace(/\./g, "");
  amount = amount.replace(/^0*/, "");
  container = document.getElementsByClassName("transaction-icon-container")[0];

  if (amount.length === 0) {
    container.classList.remove("transaction-valid");
    container.classList.remove("transaction-invalid");
    input.value = "";
    return;
  }

  valid = isValidNum(amount);

  if (valid) {
    container.classList.remove("transaction-invalid");
    container.classList.add("transaction-valid");

    decimal = (parseInt(amount) / 100).toFixed(2);
    input.value = String(decimal);

  } else {
    container.classList.remove("transaction-valid");
    container.classList.add("transaction-invalid");
  }

}
