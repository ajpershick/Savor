require 'rails_helper'

RSpec.describe BankAccount, type: :model do

  it { should belong_to(:item) }
  it { should have_many(:bank_transactions) }

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :item_id }
  it { should validate_presence_of :account_id }
  it { should validate_presence_of :available_balance }
  it { should validate_presence_of :current_balance }
  it { should validate_presence_of :name }
  it { should validate_presence_of :mask }
  it { should validate_presence_of :official_name }
  it { should validate_presence_of :account_type }
  it { should validate_presence_of :account_subtype }

  it "should have valid factory" do
    @bank_account = FactoryGirl.build(:random_bank_account)
    @bank_account.should be_valid
  end
end
