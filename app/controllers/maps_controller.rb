class MapsController < ApplicationController

  before_action :confirm_user_logged_in

  layout "menu"

  def index
    mapuser = User.find(session[:user_id])

    #grab latitude and longitude and store them in variables as well as address
    lat = mapuser.transactions.latitude.order(:date => :desc)
    long = mapuser.transactions.longitude.order(:date => :desc)

    if lat.length == 0 then
      @empty = true
      return
    end
    @empty = false

    if long.length == 0 then
      @empty = true
      return
    end
    @empty = false

    latest_lat = lat[0].date.to_date
    earliest_lat = lat[-1].date.to_date
    latest_long = long[0].date.to_date
    earliest_long = long[-1].date.to_date

    class Latlongarray
      def initialize(lat,long)
      @latlongArr = Array.new(lat) {Array.new(long)}
      end



    if (mapuser.transactions.location == true) then

      return view('viewlatlongArr')->with(@latlongArr)
      return view('viewlocationArr')->with(@locationArr)

    end


  end
end
