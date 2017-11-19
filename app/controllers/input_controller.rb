class InputController < ApplicationController

  before_action :confirm_user_logged_in

  layout "menu"

  def new
    @categories = {
      "dining"        => {icon: "cutlery",        color: "#2980b9"},
      "clothing"      => {icon: "shopping-bag",   color: "#27ae60"},
      "groceries"     => {icon: "shopping-cart",  color: "#f1c40f"},
      "automotive"    => {icon: "car",            color: "#e74c3c"},
      "gifts"         => {icon: "gift",           color: "#D2527F"},
      "entertainment" => {icon: "film",           color: "#8e44ad"},
      "recreation"    => {icon: "futbol-o",       color: "#16a085"},
      "transit"       => {icon: "bus",            color: "#59ABE3"},
      "utilities"     => {icon: "bolt",           color: "#f39c12"},
      "maintenance"   => {icon: "wrench",         color: "#7f8c8d"},
      "medical"       => {icon: "medkit",         color: "#c0392b"},
      "debt"          => {icon: "university",     color: "#bdc3c7"},
      "luxury"        => {icon: "diamond",        color: "#9b59b6"},
      "education"     => {icon: "book",           color: "#2ecc71"},
      "pets"          => {icon: "paw",            color: "#795548"},
      "insurance"     => {icon: "shield",         color: "#4183D7"},
      "supplies"      => {icon: "paperclip",      color: "#F4D03F"},
      "housing"       => {icon: "home",           color: "#26A65B"},
      "charity"       => {icon: "heart",          color: "#E08283"},
      "savings"       => {icon: "usd",            color: "#1E824C"},
      "travel"        => {icon: "plane",          color: "#e67e22"},
      "personal care" => {icon: "bath",           color: "#947CB0"},
      "taxes"         => {icon: "envelope-open-o",color: "#d35400"},
      "miscellaneous" => {icon: "thumb-tack",     color: "#2c3e50"},
    }

    @char = [
      "q", "w", "e", "r", "t", "y", "u", "i",
      "a", "s", "d", "f", "g", "h", "j", "k",
      "z", "x", "c", "v", "b", "n", "m", ",",
    ]

    @category_order = [
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
      "luxury",       #leisure?
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

  end

  def create


  end


end
