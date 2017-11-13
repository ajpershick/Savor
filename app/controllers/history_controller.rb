class HistoryController < ApplicationController

  before_action :confirm_user_logged_in

  def index
    user = User.find(session[:user_id]) # Get the current logged in user
    transactions = user.transactions.order(:date => :desc) # Get all the user's transactions
    latest_date = transactions[0].date.to_date
    earliest_date = transactions[-1].date.to_date
    # Creates an array of all months between the user's first transaction and latest transaction
    @months = (earliest_date..latest_date).map{|d| {year: d.year, month: d.month, transactions: []}}.uniq.reverse

    month_index = 0;
    transaction_index = 0;

    # Sorts all of the user's transactions into the months they occurred
    while (transaction_index < transactions.length) do

      transaction_month = transactions[transaction_index].date.to_date.month
      transaction_year = transactions[transaction_index].date.to_date.year

      while (transaction_month != @months[month_index][:month] || transaction_year != @months[month_index][:year]) do
        month_index += 1
      end

      @months[month_index][:transactions] << transactions[transaction_index]
      transaction_index+= 1

    end

    



  end

end
