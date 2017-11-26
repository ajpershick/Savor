

function toggleCategory(element) {

  if (element.classList.contains("disabled-category")) {
    element.style.backgroundColor = element.dataset.color;
    element.classList.remove("disabled-category");
  } else {
    element.style.backgroundColor = "#bdc3c7";
    element.classList.add("disabled-category");
  }

}


function enableAll() {

  categories = document.getElementsByClassName("chart-category-icon-container");

  for (var i = 0; i < categories.length; i++) {
    if (categories[i].classList.contains("disabled-category") && categories[i].id !== "enabled" && categories[i] !== "disabled") {
      toggleCategory(categories[i]);
    }
  }

}


function disableAll() {
  categories = document.getElementsByClassName("chart-category-icon-container");

  for (var i = 0; i < categories.length; i++) {
    if (!categories[i].classList.contains("disabled-category") && categories[i].id !== "category-type-disable" && categories[i] !== "category-type-enable") {
      toggleCategory(categories[i]);
    }
  }
}

// Takes any element and automatically lightens up its background color
function conditionalLightenUp(element) {

  var hex = (element.classList.contains("disabled-category")) ? "#bdc3c7" : element.dataset.color;
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
function conditionalRevertColor(element) {
  element.style.backgroundColor = (element.classList.contains("disabled-category")) ? "#bdc3c7" : element.dataset.color;
}
