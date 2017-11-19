class HistoryController < ApplicationController

  before_action :confirm_user_logged_in

  def index
    @categories = {
      "food"          => {icon: "cutlery",       color: "#2980b9"},
      "clothing"      => {icon: "shopping-bag",  color: "#27ae60"},
      "groceries"     => {icon: "shopping-cart", color: "#f1c40f"},
      "gas"           => {icon: "car",           color: "#e74c3c"},
      "gifts"         => {icon: "gift",          color: "#D2527F"},
      "entertainment" => {icon: "film",          color: "#8e44ad"},
      "recreation"    => {icon: "futbol-o",      color: "#16a085"},
      "transit"       => {icon: "bus",           color: "#59ABE3"},
      "utilities"     => {icon: "bolt",          color: "#f39c12"},
      "maintenance"   => {icon: "wrench",        color: "#7f8c8d"},
      "emergency"     => {icon: "medkit",        color: "#c0392b"},
      "debt"          => {icon: "usd",           color: "#bdc3c7"},
      "luxury"        => {icon: "diamond",       color: "#9b59b6"},
      "education"     => {icon: "book",          color: "#2ecc71"},
    }



    if params[:month].blank? || params[:year].blank? then
      today = Date.today
      @formatted_month = Date::MONTHNAMES[today.month] + " " + today.year.to_s
      @selected_month = today.month.to_s
      @selected_year = today.year.to_s
    else
      @formatted_month = Date::MONTHNAMES[params[:month].to_i] + " " + params[:year].to_s
      @selected_month = params[:month]
      @selected_year = params[:year]
    end

    if params[:order].blank? then
      @order = "latest"
    else
      @order = params[:order]
    end

    user = User.find(session[:user_id]) # Get the current logged in user
    transactions = user.transactions.order(:date => :desc) # Get all the user's transactions
    latest_date = transactions[0].date.to_date
    earliest_date = transactions[-1].date.to_date
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

    current_index =  @month_range.each_index.detect{|i| @month_range[i][:year].to_s == @selected_year && @month_range[i][:month].to_s == @selected_month}

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

    if @order == "earliest" then
      @transaction_days.reverse!
    end

    @total_amount = 0
    @total_items = 0

    @transaction_days.each do |day|
      day[:transactions].each do |t|
        @total_amount += t.amount
        @total_items += 1
      end
    end

    puts @total_amount
    puts @total_items

  end

end
