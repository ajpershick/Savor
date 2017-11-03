class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def confirm_user_logged_in
    if !session[:user_id]
      redirect_to({controller: "access", action: "login"})
    elsif session[:admin]
      redirect_to({controller: "admin", action: "index"})
    end
  end

  def confirm_admin_logged_in
    if !session[:user_id]
      redirect_to({controller: "access", action: "login"})
    elsif !session[:admin]
      redirect_to({controller: "home", action: "index"})
    end
  end

  def confirm_logged_out
    if session[:user_id]
      puts session[:user_id]
      if session[:admin]
        redirect_to({controller: "admin", action: "index"})
      else
        redirect_to({controller: "home", action: "index"})
      end

    end

  end

end
