FactoryGirl.define do

  factory :random_bank_transaction, class: BankTransaction do

    validates :user_id, presence: true
    validates :item_id, presence: true
    validates :bank_account_id, presence: true
    validates :transaction_id, presence: true
    validates :category, presence: true
    validates :category_id, presence: true
    validates :transaction_type, presence: true
    validates :amount, presence: true
    validates :date, presence: true
    validates :location_bool, presence: true
    validates :location, presence: true
    validates :name, presence: true
    validates :pending, presence: true
    validates :pending_transaction_id, presence: true

  end
end
