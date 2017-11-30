class Item < ApplicationRecord
  belongs_to :user
  self.primary_key = 'item_id'

  has_many :bank_accounts, dependent: :destroy
  #when item.destroy is called, the item's bank accounts are also deleted
end
