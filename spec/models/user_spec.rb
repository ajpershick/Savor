require 'rails_helper'

RSpec.describe User, type: :model do

  it { should have_many(:transactions)}
  it { should have_many(:items)}
  it { should have_many(:incomes)}
  it { should have_one(:account_balance)}

  it { should validate_presence_of :name }
  it { should validate_presence_of :username }
  it { should validate_presence_of :email }
  it { should validate_presence_of :password_digest }

  it "should have valid factory" do
    @user = FactoryGirl.build(:random_user)
    @user.should be_valid
  end

end
