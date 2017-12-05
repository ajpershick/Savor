class HistoryController < ApplicationController

  before_action :confirm_user_logged_in

  layout "menu"

  def index
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
      "services"      => {icon: "cog",            color: "#7f8c8d"},
      "medical"       => {icon: "medkit",         color: "#c0392b"},
      "debt"          => {icon: "university",     color: "#95a5a6"},
      "luxury"        => {icon: "diamond",        color: "#9b59b6"},
      "education"     => {icon: "book",           color: "#2ecc71"},
      "pets"          => {icon: "paw",            color: "#795548"},
      "insurance"     => {icon: "shield",         color: "#4183D7"},
      "supplies"      => {icon: "paperclip",      color: "#F4D03F"},
      "housing"       => {icon: "home",           color: "#26A65B"},
      "charity"       => {icon: "heart",          color: "#E08283"},
      "banking"       => {icon: "usd",            color: "#1E824C"},
      "travel"        => {icon: "plane",          color: "#e67e22"},
      "personal care" => {icon: "bath",           color: "#947CB0"},
      "electronics"   => {icon: "camera",         color: "#d35400"},
      "miscellaneous" => {icon: "thumb-tack",     color: "#2c3e50"},
      "total"         => {icon: "calculator",     color: "#1d1d1d"},
    }

    if params[:order].blank? then
      @order = "latest"
    else
      @order = params[:order]
    end

    # Get the current logged in user
    user = User.find(session[:user_id])
    # Get all the user's transactions
    transactions = user.transactions.order(:date => :desc)

    if transactions.length == 0 then
      @empty = true
      return
    end
    @empty = false

    latest_date = transactions[0].date.to_date
    earliest_date = transactions[-1].date.to_date

    if params[:month].blank? || params[:year].blank? then
      today = latest_date
      @formatted_month = Date::MONTHNAMES[today.month] + " " + today.year.to_s
      @selected_month = today.month.to_s
      @selected_year = today.year.to_s
    else
      @formatted_month = Date::MONTHNAMES[params[:month].to_i] + " " + params[:year].to_s
      @selected_month = params[:month]
      @selected_year = params[:year]
    end

    # Creates an array of all months between the user's first transaction and latest transaction
    @month_range = (earliest_date..latest_date).map{|d| {year: d.year, month: d.month}}.uniq.reverse

    # Gets all month with the selected month
    month_transactions = transactions.where('extract(year from date) = ?', @selected_year).where('extract(month from date) = ?', @selected_month)

    @transaction_days = []
    day_index = -1;
    transaction_index = 0;

    # Sorts all transactions for the selected month into days
    while (transaction_index < month_transactions.length) do
      if (day_index != -1 && month_transactions[transaction_index].date == @transaction_days[day_index][:date]) then
        @transaction_days[day_index][:transactions] << month_transactions[transaction_index]
      else
        @transaction_days << {date: month_transactions[transaction_index].date, transactions: [month_transactions[transaction_index]]}
        day_index += 1
      end
      transaction_index += 1
    end

    # Gets the index of the currently selected month/year combination
    current_index =  @month_range.each_index.detect{|i| @month_range[i][:year].to_s == @selected_year && @month_range[i][:month].to_s == @selected_month}

    # Calculates the next and previous months, if they exist
    if current_index == @month_range.length - 1 then
      @previous_month = nil
      @previous_year = nil
    else
      @previous_month = @month_range[current_index + 1][:month]
      @previous_year = @month_range[current_index + 1][:year]
    end

    if current_index == 0 then
      @next_month = nil
      @next_year = nil
    else
      @next_month = @month_range[current_index - 1][:month]
      @next_year = @month_range[current_index - 1][:year]
    end

    # Change the order transactions appear in
    if @order == "earliest" then
      @transaction_days.reverse!
    end

    @transaction_days.each do |day|
      day[:transactions].sort!{|x, y| x.created_at <=> y.created_at}
      if @order == "latest" then day[:transactions].reverse! end
    end

    @total_amount = 0
    @total_items = 0

    # Calculate the total amount of money spent, and total transactions made during the month
    @transaction_days.each do |day|
      day[:transactions].each do |t|
        @total_amount += t.amount
        @total_items += 1
      end
    end

  end

  def income
    user = User.find(session[:user_id])
    #@incomes_sorted = user.incomes.sort_by {|income| income.created_at}
    @incomes_sorted = user.incomes.order(created_at: :desc, source: :desc)
    @empty = (@incomes_sorted == nil)
  end

end
