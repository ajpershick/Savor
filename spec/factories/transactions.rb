FactoryGirl.define do
  sequence(:user_id) { |n| n }

  factory :random_transaction, class: Transaction do
    user_id {FactoryGirl.generate :user_id}
    amount {Faker::Number.number}
    date {Faker::Date.forward}
    category {Faker::Team.state}
    transaction_type {Faker::Superhero.prefix}
    location {Faker::University.name}
    latitude {Faker::Address.latitude}
    longitude {Faker::Address.longitude}
  end
end

