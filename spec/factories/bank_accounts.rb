FactoryGirl.define do

  factory :random_bank_account, class: BankAccount do
    user_id {FactoryGirl.generate :user_id}
    item_id {Faker::Number.number}
    account_id {Faker::Number.number}
    amount {Faker::Number.number}
    available_balance {Faker::Number.number}
    current_balance {Faker::Number.number}
    name {Faker::Superhero.prefix}
    mask {Faker::University.name}
    official_name {Faker::Superhero.prefix}
    account_type {Faker::Superhero.prefix}
    account_subtype {Faker::Superhero.prefix}
  end
end
