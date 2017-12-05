FactoryGirl.define do

  factory :random_item, class: Item do
    user_id {FactoryGirl.generate :user_id}
    access_token {Faker::Internet.password}
  end
end

