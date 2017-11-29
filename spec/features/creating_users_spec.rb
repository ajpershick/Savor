# require 'rails_helper'
#
# feature "get new_user" do
#   it "normal user can't get new_index" do
#     @admin = build(:random_admin)
#     login(@admin)
#     login_admin
#     page.set_rack_session(user: @admin.id)
#     page.set_rack_session(admin: true)
#     visit '/admin/new_user'
#     expect(page).to have_current_path('admin/new_user')
#     fill_in 'Username', with: 'Bobby', :match => :prefer_exact
#     fill_in 'First Name', with: 'Bob', :match => :prefer_exact
#     fill_in 'Email', with: 'Bob@bob.com', :match => :prefer_exact
#     fill_in 'Password', with: 'password', :match => :prefer_exact
#     fill_in 'confirm_pass', with: 'password', visible: false
#     click_button 'Submit', :match => :prefer_exact
#     expect(page).to have_current_path(new_user_path, url: true)
#     expect(page).to have_css 'Bob'
#   end
# end