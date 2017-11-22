// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require ./access
//= require ./account
//= require ./admin
//= require ./home
//= require ./recommendations
//= require ./spending_history.coffee
//= require ./input

function myFunction() { //toggles the side-nav
    var x = document.getElementById("mySideNav");
    if (x.className === "side-navigation") {
        x.className += " open";
    } else {
        x.className = "side-navigation";
    }
}

function linkDelay(URL) { //collapses side-nav, then goes to link
  console.log("started link delay");
  myFunction();
  console.log("executed myFunction");
  gotoLink(URL);
}

function gotoLink(URL) { //opens URL after 0.5 s
  setTimeout(function() {window.location = URL}, 500);
}

//start of sidenav dropdown menu
function showSubpages(subpage1, subpage2, subpage3, subpage4, subpage5, subpage6) {
  var subpages = [subpage1, subpage2, subpage3, subpage4, subpage5, subpage6];
  var i = 0;
  var x;
  for(var i = 0; i < subpages.length; i++) {
    if(subpages[i] == null) {
      break;
    }
    x = document.getElementById(subpages[i]);
    if (x.className === "subpage-button") {
      x.className += " open";
    }
    else {
      x.className = "subpage-button";
    }
  }
}

function closeMessage() { //toggles the side-nav
  console.log("executed closeMessage")
    var x = document.getElementById("message");
    //if (x.className === "message") {
        x.className += " close";
    //}
}
//end of sidenav dropdown menu

/*
//start of top nav dropdown menu
function myFunction(id) {
    document.getElementById(id).classList.toggle("show");
}

// Close the dropdown if the user clicks outside of it
window.onclick = function(event) {
  if (!event.target.matches('.dropbtn')) {

    var dropdowns = document.getElementsByClassName("dropdown-content");
    var i;
    for (i = 0; i < dropdowns.length; i++) {
      var openDropdown = dropdowns[i];
      if (openDropdown.classList.contains('show')) {
        openDropdown.classList.remove('show');
      }
    }
  }
}
//end of top nav dropdown menu
*/

//= require serviceworker-companion
