FactoryGirl.define do
  sequence(:email) { |n| "user#{n}@factory.com" }
  sequence(:username) { |n| "user#{n}" }

  factory :user do
    name 'Savor'
    email {FactoryGirl.generate :email}
    username {FactoryGirl.generate :username}
    password_digest 'password'
    admin false
  end

  # This will use the User class (Admin would have been guessed)
  factory :admin, class: User do
    name 'Admin'
    email {FactoryGirl.generate :email}
    username {FactoryGirl.generate :username}
    password_digest 'password'
    admin true
  end
end

