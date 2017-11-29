FactoryGirl.define do

  factory :random_account_balance, class: AccountBalance do
    user_id {FactoryGirl.generate :user_id}
    bank_balance {Faker::Number.decimal}
    cash_balance {Faker::Number.decimal}
    total_balance {Faker::Number.decimal}
  end
end
