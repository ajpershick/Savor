require 'rails_helper'

RSpec.describe BankTransaction, type: :model do

  it { should belong_to(:item) }
  it { should have_many(:bank_transactions) }

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :item_id }
  it { should validate_presence_of :bank_account_id }
  it { should validate_presence_of :transaction_id }
  it { should validate_presence_of :category }
  it { should validate_presence_of :category_id }
  it { should validate_presence_of :transaction_type }
  it { should validate_presence_of :amount }
  it { should validate_presence_of :date }
  it { should validate_presence_of :location_bool }
  it { should validate_presence_of :location }
  it { should validate_presence_of :name }
  it { should validate_presence_of :pending }
  it { should validate_presence_of :pending_transaction_id }

  it "should have valid factory" do
    @bank_transaction = FactoryGirl.build(:random_bank_transaction)
    @bank_transaction.should be_valid
  end
end
