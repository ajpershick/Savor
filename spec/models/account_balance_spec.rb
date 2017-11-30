require 'rails_helper'

RSpec.describe AccountBalance, type: :model do

  it { should belong_to(:user)}

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :bank_balance }
  it { should validate_presence_of :cash_balance }
  it { should validate_presence_of :total_balance }

  it "should have valid factory" do
    FactoryGirl.build(:random_account_balance).should be_valid
  end
end
