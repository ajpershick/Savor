require 'rails_helper'

feature 'Test login', type: :feature do
  # include SpecTestHelper

  before(:each) do
    @user = create(:random_user)
    expect(ApplicationController.any_instance.stub(:confirm_logged_out)).to be_truthy
  end

  scenario 'a user fills out the form and tries to login' do
    visit access_login_path
    expect(page).to have_current_path('/access/login')
    within('#login-entry', visible: false) do
      fill_in 'Username', with: @user.username
      fill_in 'Password', with: 'testpassword'
      click_button 'Log In'
    end
    expect(page).to have_current_path('/input/new')
  end

  scenario 'testing login helper' do
    login_feature(@user)
    expect(page).to have_current_path('/input/new')
  end

end
