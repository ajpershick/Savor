FactoryGirl.define do

  factory :random_bank_transaction, class: BankTransaction do
    user_id {FactoryGirl.generate :user_id}
    item_id {Faker::Number.number}
    bank_account_id {Faker::Number.number}
    account_id {Faker::Number.number}
    transaction_id {Faker::Number.number}
    category [Faker::Superhero.prefix]
    category_id {Faker::Number.number}
    transaction_type {Faker::University.name}
    amount {Faker::Number.number}
    date {Faker::Date.backward}
    location_bool {Faker::Boolean.boolean}
    location [Faker::Address.latitude, Faker::Address.longitude]
    name {Faker::Name.name}
    pending {Faker::Boolean.boolean}
    pending_transaction_id {Faker::Number.number}
  end
end
