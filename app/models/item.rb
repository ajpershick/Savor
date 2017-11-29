class Item < ApplicationRecord

  belongs_to :user

  validates :user_id, presence: true
  validates :access_token, presence: true
end
