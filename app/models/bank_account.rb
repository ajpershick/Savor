class BankAccount < ApplicationRecord

  belongs_to :item
  has_many :bank_transactions

  validates :user_id, presence: true
  validates :item_id, presence: true
  validates :account_id, presence: true
  validates :available_balance, presence: true
  validates :current_balance, presence: true
  validates :name, presence: true
  validates :mask, presence: true
  validates :official_name, presence: true
  validates :account_type, presence: true
  validates :account_subtype, presence: true
end
