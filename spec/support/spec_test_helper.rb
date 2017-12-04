module SpecTestHelper

  def login_admin
    session[:admin] = true
  end

  def login(user)
    session[:user_id] = user.id
  end

  def current_user
    User.find(request.session[:user_id])
  end

  def logout
    session[:user_id] = nil
    session[:admin] = nil
  end

  def login_feature(user)
    visit access_login_path
    expect(page).to have_current_path('/access/login')
    within('#login-entry', visible: false) do
      fill_in 'Username', with: user.username
      fill_in 'Password', with: 'testpassword'
      click_button 'Log In'
    end
  end


end
