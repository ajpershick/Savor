require 'rails_helper'

RSpec.feature "ManualInputs", type: :feature do

  # scenario 'user inputs something manually with no money' do
  #   @user = create(:random_user)
  #   @transaction = create(:random_transaction)
  #   login_feature(@user)
  #   expect(page).to have_current_path('/')
  #   visit input_new_path
  #   expect(page).to have_current_path('/input/new')
  #   fill_in '0.00', with: @transaction.amount
  #   find('#category-type-services', visible: false).click
  #   fill_in 'Description', with: @transaction.category
  #   fill_in 'Location', with: @transaction.location_name
  #   click_button 'Save transaction'
  #   expect(page).to have_current_path('/input/new?message=Error%2C+insufficient+funds+in+your+cash+account+balance+to+make+this+transaction')
  # end

  scenario 'user inputs something with enough money' do
    @user = create(:random_user)
    @income = create(:random_income)
    @transaction = create(:random_transaction)
    login_feature(@user)
    expect(page).to have_current_path('/')
    getsomemoney
    visit input_new_path
    expect(page).to have_current_path('/input/new')
    fill_in '0.00', with: @transaction.amount
    find('#category-type-services', visible: false).click
    fill_in 'Description', with: @transaction.category
    fill_in 'Location', with: @transaction.location_name
    find('#transaction-date-input').set 'Mon Dec 03 2017'
    click_button 'Save transaction'
    expect(page).to have_current_path('/input/new?message=Error%2C+insufficient+funds+in+your+cash+account+balance+to+make+this+transaction')
  end


end
