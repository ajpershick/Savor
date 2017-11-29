require 'rails_helper'

RSpec.describe Income, type: :model do

  it { should belong_to(:user)}

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :income_amount }
  it { should validate_presence_of :source }

  it "should have valid factory" do
    FactoryGirl.build(:random_income).should be_valid
  end
end
