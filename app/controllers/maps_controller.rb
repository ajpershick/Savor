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

    if !@empty then
      @max_lat = current_transactions[0].latitude.to_f
      @min_lat = current_transactions[0].latitude.to_f
      @max_long = current_transactions[0].longitude.to_f
      @min_long = current_transactions[0].longitude.to_f
    end

    @locations = []
    current_transactions.each do |transaction|
      lat = transaction.latitude.to_f
      long = transaction.longitude.to_f
      @locations << [lat, long]

      if lat > @max_lat then
        @max_lat = lat
      elsif lat < @min_lat then
        @min_lat = lat
      end

      if long > @max_long then
        @max_long = long
      elsif long < @min_long then
        @min_long = long
      end
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
