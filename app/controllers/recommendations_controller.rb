class RecommendationsController < ApplicationController

  before_action :confirm_user_logged_in

  layout "menu"

  def index
  end
end
