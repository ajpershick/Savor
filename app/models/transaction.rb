class Transaction < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :amount, presence: true
  validates :date, presence: true
  validates :category, presence: true
  validates :transaction_type, presence: true

end
