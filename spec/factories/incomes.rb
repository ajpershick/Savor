FactoryGirl.define do

  factory :random_income, class: Income do
    user_id {FactoryGirl.generate :user_id}
    income_amount {Faker::Number.decimal}
    date {'2017-02-11'}
    source {Faker::StarTrek.character}

  end
end
