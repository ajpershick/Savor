class Transaction < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :amount, presence: true
  validates :date, presence: true
  validates :category, presence: true
  validates :transaction_type, presence: true
  validates :location, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

end
