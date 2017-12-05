require 'rails_helper'

feature 'Signup', type: :feature do
  # include SpecTestHelper

  before(:each) do
    @user = create(:random_user)
    ApplicationController.any_instance.stub(:confirm_logged_out)
  end

  scenario 'a user fills out the form and tries to sign up with ' do
    visit access_login_path
    expect(page).to have_current_path('/access/login')
    within('#signup-entry', visible: false) do
      fill_in 'Username', with: @user.username, :match => :prefer_exact
      fill_in 'First Name', with: @user.name, :match => :prefer_exact
      fill_in 'Email', with: @user.email, :match => :prefer_exact
      fill_in 'Password', with: 'password', :match => :prefer_exact
      fill_in 'Confirm password', with: 'password', :match => :prefer_exact
      click_button 'Sign up', :match => :prefer_exact
    end
    expect(page).to have_current_path('/input/new?message=Successfully+created+new+account+with+account+balance+of+0.')
  end

end
