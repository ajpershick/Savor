require 'rails_helper'

RSpec.describe Item, type: :model do

  it { should belong_to(:user)}
  it { should have_many(:bank_accounts)}

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :access_token }

  it "should have valid factory" do
    FactoryGirl.build(:random_item).should be_valid
  end
end
