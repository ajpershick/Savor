class Item < ApplicationRecord
  belongs_to :user
  self.primary_key = 'item_id'
end
