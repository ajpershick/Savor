class AccountBalance < ApplicationRecord

  belongs_to :user

  validates :user_id, presence: true
  validates :bank_balance, presence: true
  validates :cash_balance, presence: true
  validates :total_balance, presence: true
end
