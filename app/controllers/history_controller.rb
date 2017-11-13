class HistoryController < ApplicationController

  before_action :confirm_user_logged_in

  def index
    @categories = {
      "food"      => {icon: "cutlery",       color: "#2980b9"},
      "clothing"  => {icon: "shopping-bag",  color: "#27ae60"},
      "groceries" => {icon: "shopping-cart",       color: "#f1c40f"},
      "gas"       => {icon: "car",           color: "#e74c3c"},

    }



    if params[:month].blank? || params[:year].blank? then
      today = Date.today
      @formatted_month = Date::MONTHNAMES[today.month] + " " + today.year.to_s
      @selected_month = today.month
      @selected_year = today.year
    else
      @formatted_month = Date::MONTHNAMES[params[:month].to_i] + " " + params[:year].to_s
      @selected_month = params[:month]
      @selected_year = params[:year]
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

  end

end
