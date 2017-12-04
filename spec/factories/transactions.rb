FactoryGirl.define do
  sequence(:user_id) { |n| n }

  factory :random_transaction, class: Transaction do
    user_id {FactoryGirl.generate :user_id}
    unique_id {Faker::Number.number}
    amount {Faker::Number.decimal}
    date {Date.today.to_s}
    category {Faker::Team.state}
    transaction_type {Faker::Superhero.prefix}
    location {true}
    location_name {Faker::University.name}
    latitude {Faker::Address.latitude}
    longitude {Faker::Address.longitude}
  end
end

