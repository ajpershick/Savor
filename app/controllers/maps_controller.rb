class MapsController < ApplicationController

  before_action :confirm_user_logged_in

  layout "menu"

  def index
    user = User.find(session[:user_id])

    transactions = user.transactions.where(location: true).order(:date => :asc)

    if transactions.length == 0 then
      @empty = true
      return
    end
    @empty = false

    earliest_date = transactions[0].date.to_date
    latest_date = transactions[-1].date.to_date

    # Creates an array of all months, or all years, from the user's first transaction to their latest transaction
    @year_range = (earliest_date..latest_date).map{|d| d.year.to_s}.uniq.reverse

    if params[:month].blank? then
      @selected_month = latest_date.month.to_s
    else
      @selected_month = params[:month]
    end

    if params[:year].blank? then
      @selected_year = latest_date.year.to_s
    else
      @selected_year = params[:year]
    end

    @year_view = (@selected_month == "0")

    if @year_view then
      current_transactions = transactions.where('extract(year from date) = ?', @selected_year)
    else
      current_transactions = transactions.where('extract(year from date) = ?', @selected_year).where('extract(month from date) = ?', @selected_month)
    end

    @locations = []
    current_transactions.each do |transaction|
      lat = transaction.latitude
      long = transaction.longitude
      @locations << [lat, long]
    end

    #
    # @locations =  [
    #   [49.2827, -123.1207],
    #   [49.2837, -123.1207],
    #   [49.2847, -123.1207],
    #   [49.2857, -123.1307],
    #   [49.2827, -123.1407],
    #   [49.2827, -123.1257],
    #   [49.2827, -123.1267],
    #   [49.2827, -123.1277],
    # ]

  end
end
