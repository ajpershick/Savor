class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true
  validates :username, presence: true
  validates :password_digest, presence: true
  has_secure_password
  has_many :transactions
  has_many :items
  has_one :account_balance
  has_many :incomes
end
