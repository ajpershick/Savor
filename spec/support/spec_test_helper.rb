module SpecTestHelper

  def login_admin
    request.session[:admin] = true
  end

  def login(user)
    request.session[:user_id] = user.id
  end

  def current_user
    User.find(request.session[:user_id])
  end

  def logout
    session[:user_id] = nil
    session[:admin] = nil
  end
end
