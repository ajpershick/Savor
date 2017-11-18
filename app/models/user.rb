class User < ApplicationRecord
  has_secure_password
  has_many :transactions
  has many :items
end
