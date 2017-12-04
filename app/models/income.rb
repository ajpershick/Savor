class Income < ApplicationRecord

  belongs_to :user

  validates :user_id, presence: true
  validates :income_amount, presence: true
  validates :source, presence: true
  validates :date, presence: true
end
