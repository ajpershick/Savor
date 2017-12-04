FactoryGirl.define do

  factory :random_income, class: Income do
    user_id {FactoryGirl.generate :user_id}
    income_amount {Faker::Number.decimal}
    source {Faker::StarTrek.character}
    date {Date.today.to_s}
  end
end
