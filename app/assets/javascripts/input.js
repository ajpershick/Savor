
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
