class HomeController < ApplicationController

  before_action :confirm_user_logged_in

  layout "menu"

  def index
    #@name = User.where(id: session[:user_id]).first.name
  end
end
