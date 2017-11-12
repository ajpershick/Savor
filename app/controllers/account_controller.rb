class AccountController < ApplicationController
  layout "menu"
  def edit
    @username = session[:username]
    @first_name = session[:name]
    @email = session[:email]
  end

  def make_edit
  end

  def index
  end
end
