class MapsController < ApplicationController

  before_action :confirm_user_logged_in

  layout "menu"

  def index
    mapuser = User.find(session[:user_id])

    if mapuser.transactions.location == true
      #grab latitude and longitude and store them in variables as well as address
      lat = mapuser.transactions.latitude
      long = mapuser.transactions.longitude

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


      def initialize(lat,long)
        @latlongArr = Array.new(lat) {Array.new(long)}
      end

        return view('viewlatlongArr')->with(@latlongArr)

    end
  end
end
