require 'rails_helper'

RSpec.describe Transaction, type: :model do

  it { should belong_to(:user)}

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :amount }
  it { should validate_presence_of :date }
  it { should validate_presence_of :category }
  it { should validate_presence_of :transaction_type }
  it { should validate_presence_of :location }
  it { should validate_presence_of :latitude }
  it { should validate_presence_of :longitude }
end
