
function refreshPage() {
  window.location.replace(document.getElementById('hidden-link').href);
}


function toggleCategory(element, full) {

  links = document.getElementsByTagName("a");

  var value;
  if (element.classList.contains("disabled-category")) {
    element.style.backgroundColor = element.dataset.color;
    element.classList.remove("disabled-category");
    document.getElementsByClassName("chart-canvas")[0];
    value = element.dataset.binary;
  } else {
    element.style.backgroundColor = "#bdc3c7";
    element.classList.add("disabled-category");
    value = -1 * element.dataset.binary;
  }

  for (var i = 0; i < links.length; i++) {
    var href = links[i].href
    if (href.indexOf("?categories") === -1) continue;
    var first = href.indexOf("=");
    var second = href.indexOf("&");

    var start = href.slice(0, first + 1);
    var num = href.slice(first + 1, second);
    var end = href.slice(second);

    if (full === true) {
      links[i].href = start + String(Math.pow(2, 24) - 1) + end;
    } else if (full === false) {
      links[i].href = start + String(0) + end;
    } else {
      links[i].href = start + String(parseInt(num) + value) + end;
    }
  }
}


function enableAll() {

  categories = document.getElementsByClassName("chart-category-icon-container");

  for (var i = 0; i < categories.length; i++) {
    if (
      categories[i].classList.contains("disabled-category") &&
      categories[i].id !== "category-type-enabled" &&
      categories[i].id !== "category-type-disabled") {

      toggleCategory(categories[i], true);
    }
  }

}


function disableAll() {
  categories = document.getElementsByClassName("chart-category-icon-container");

  for (var i = 0; i < categories.length; i++) {
    if (
      !categories[i].classList.contains("disabled-category") &&
      categories[i].id !== "category-type-disable" &&
      categories[i].id !== "category-type-enable") {

      toggleCategory(categories[i], false);
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
