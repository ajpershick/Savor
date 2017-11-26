class InputController < ApplicationController

  before_action :confirm_user_logged_in

  layout "menu"

  def new
    @message = params[:message]

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
      "debt"          => {icon: "university",     color: "#95a5a6"},
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
    new_transaction = Transaction.new(
      user_id: session[:user_id],
      amount: params[:amount],
      date: Date.today,
      category: params[:category],
      transaction_type: "place",
      unique_id: rand(0..100000).to_s,
      location_name: params[:location_name]
    )
    @amount = params[:amount]

    if new_transaction.save
      puts "Cash transaction successfully saved, redirecting to account_balance/update"
      redirect_to({controller: "account_balance", action: "update", amount: @amount, next_controller:"input", next_action: "new", trans_type: "cash"})
      #redirect_to({controller: "input", action: "new"})
    end
  end

#creates a new income in database with params: income_amount, source
  def create_income
    @income_amount = params[:amount]
    @source = params[:source]

    #check that it was a valid income entry
    income_float = @income_amount.to_f
    income_string_round2 = "%0.2f" % income_float #rounds income_float to two decimal places and converts to string form
    income_is_valid = income_string_round2 == @income_amount.to_s

    #check that source is less than 30 characters
    source_is_too_big = @source.length > 30

    #if our checks return false, then redirect back to input/income with error message
    if(income_is_valid == false)
      puts "income is not a number"
      redirect_to({controller: "input", action: "income", message: "Failed to enter income entry, income amount is not invalid. Please try again."}) and return
    elsif (source_is_too_big == true)
      puts "source is too big"
      redirect_to({controller: "input", action: "income", message: "Failed to enter income entry. The source must be less than 30 characters. Please try again."}) and return
    else
      new_income = Income.new(
        user_id: session[:user_id],
        income_amount: params[:amount],
        source: params[:source]
      )

      if new_income.save
        puts "Cash income successfully saved, redirecting to account_balance/update"
        redirect_to({controller: "account_balance", action: "update", amount: @income_amount, next_controller:"input", next_action: "income", trans_type: "income-cash"}) and return
      end
    end
  end

  def income
    @message = params[:message]
  end

end
