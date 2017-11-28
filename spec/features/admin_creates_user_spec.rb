require "rails_helper"

feature 'User creates a foobar' do
  scenario 'they see the foobar on the page' do
    visit 'admin/new_user'

    fill_in 'Username', with: 'Bobby', :match => :prefer_exact
    fill_in 'First Name', with: 'Bob', :match => :prefer_exact
    fill_in 'Email', with: 'Bob@bob.com', :match => :prefer_exact
    fill_in 'Password', with: 'password', :match => :prefer_exact
    fill_in 'confirm_pass', with: 'password', visible: false
    click_button 'Submit', :match => :prefer_exact
    response.should redirect_to 'admin/index'
    expect(page).to have_css 'Bob'
  end
end
