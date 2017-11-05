class AccessController < ApplicationController

  before_action :confirm_logged_out, only: [:login]

  def login

  end

  def attempt_login
    if params[:username].present? && params[:password].present?
      user = User.where(username: params[:username]).first
      if user
        authenticated_user = user.authenticate(params[:password])
      end
    else
      flash[:invalid] = "Enter your username and password"
      redirect_to(controller: "access", action: "login", username: params[:username])
      return
    end

    if authenticated_user
      session[:user_id] = authenticated_user.id
      if user.admin
        session[:admin] = true
        redirect_to(controller: "admin", action:"index")
      else
        redirect_to(controller: "home", action: "index")
      end
    else
      flash[:invalid] = "Invalid username or password"
      redirect_to(controller: "access", action: "login", username: params[:username])
    end
  end

  def sign_up
    new_user = User.new(username: params[:username], name: params[:name], email: params[:email], password: params[:password])
    if new_user.save
      session[:user_id] = new_user.id
      redirect_to({controller: "home", action: "index"})
    else
      redirect_to({controller: "access", action: "login"})
    end
  end

  def logout
    reset_session
    redirect_to(controller: "access", action: "login")
  end

end