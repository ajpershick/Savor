class Item < ApplicationRecord

  belongs_to :user

  validates :user_id, presence: true
  validates :income_amount, presence: true
end
