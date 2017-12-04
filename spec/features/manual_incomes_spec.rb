require 'rails_helper'

RSpec.feature "ManualIncome", type: :feature do
  scenario 'user inputs money into account' do
    @user = create(:random_user)
    @income = create(:random_income)
    # @income = create(:random_income)
    login_feature(@user)
    expect(page).to have_current_path('/input/new')
    visit input_income_path
    expect(page).to have_current_path('/input/income')
    fill_in '0.00', with: @income.income_amount
    fill_in 'Source', with: 'miscellaneous'
    click_button 'Save'
    expect(page).to have_current_path('/input/income?message=Transaction+saved%2C+successfully+updated+account+balance')
  end
end

