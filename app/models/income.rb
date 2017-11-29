class Income < ApplicationRecord

  belongs_to :user

  validates :user_id, presence: true
  validates :access_token, presence: true
  validates :income_amount, presence: true
  validates :source, presence: true
end
