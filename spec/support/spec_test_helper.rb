module SpecTestHelper

  def login_admin
    login(:admin)
  end

  def login(user)
    request.session[:user_id] = user.id
    request.session[:admin] = true
  end

  def current_user
    User.find(request.session[:user])
  end
end
