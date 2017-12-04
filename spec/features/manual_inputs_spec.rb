require 'rails_helper'

RSpec.feature "ManualInputs", type: :feature do

  scenario 'user inputs something manually with no money' do
    @user = create(:random_user)
    @transaction = create(:random_transaction)
    login_feature(@user)
    expect(page).to have_current_path('/')
    visit input_new_path
    expect(page).to have_current_path('/input/new')
    fill_in '0.00', with: @transaction.amount
    find('#category-type-services', visible: false).click
    fill_in 'Location name', with: @transaction.location
    click_button 'Save transaction'
    expect(page).to have_current_path('/input/new?message=Error%2C+insufficient+funds+in+your+cash+account+balance+to+make+this+transaction')
  end

  scenario 'user inputs something with enough money' do
    @user = create(:random_user)
    @transaction = create(:random_transaction)
    @income = create(:random_income)
    login_feature(@user)
    expect(page).to have_current_path('/')
    visit input_income_path
    expect(page).to have_current_path('/input/income')
    fill_in '0.00', with: @transaction.amount
    fill_in 'Source', with: @income.source
    click_button 'Save'


    # visit input_new_path
    # expect(page).to have_current_path('/input/new')
    # fill_in '0.00', with: @transaction.amount
    # find('#category-type-services', visible: false).click
    # fill_in 'Location name', with: @transaction.location
    # click_button 'Save transaction'
    # expect(page).to have_current_path('/input/new?message=Error%2C+insufficient+funds+in+your+cash+account+balance+to+make+this+transaction')
  end


end
