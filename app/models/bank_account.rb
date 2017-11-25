class BankAccount < ApplicationRecord
  belongs_to :item
  has_many :bank_transactions
end
