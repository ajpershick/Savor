require 'rails_helper'

feature "get new_user" do
  it "Creates a new user and displays them in admin/index" do
    @admin = create(:random_admin)
    # login(@admin)
    # login_admin
    ApplicationController.any_instance.stub(:confirm_admin_logged_in)
    # page.set_rack_session(user: @admin.id)
    # page.set_rack_session(admin: true)
    visit 'admin/new_user'
    expect(page).to have_current_path('/admin/new_user')
    within('#create_account') do
      fill_in 'Username', with: 'Bobby', :match => :prefer_exact
      fill_in 'First Name', with: 'Bob', :match => :prefer_exact
      fill_in 'Email', with: 'Bob@bob.com', :match => :prefer_exact
      fill_in 'Password', with: 'password', :match => :prefer_exact
      fill_in 'confirm_pass', with: 'password', visible: false
      click_button 'Submit', :match => :prefer_exact
    end
    expect(page).to have_current_path('/admin/index')
    expect(page).to have_selector("td", text: @admin.username)
  end
end