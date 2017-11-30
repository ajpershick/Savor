class Item < ApplicationRecord
  belongs_to :user
  self.primary_key = 'item_id'

  has_many :bank_accounts

  validates :user_id, presence: true
  validates :access_token, presence: true
end
