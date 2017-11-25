class CreateBankAccounts < ActiveRecord::Migration[5.1]
  def up
    create_table :bank_accounts do |t|
      t.integer "user_id" # References the user that the item belongs to

      t.string "item_id" #The unique of the item that this account belongs to

      t.string "account_id" #The unique ID of the account
                            # In some instances, account ID's may change

      t.string "institution_id" #The financial institution associated with the Account. (TD, BMO, RBC, etc.)

      t.decimal "available_balance", :default => 0.00, :precision => 15, :scale => 2

      t.decimal "current_balance", :default => 0.00, :precision => 15, :scale => 2
        #eg
          #{}"balances": {
          #{}"available": 100, # the current balance less any outstanding holds or debits that have not yet posted to the account.
          #{}"current": 110, #  the total amount of funds in the account
          #{}"limit": null # we dont care
          #},m

      t.string "name" #The name of the Account, either assigned by the user or the financial institution itself.

      t.string "mask" #The last four digits of the Account's number.

      t.string "official_name" #The last four digits of the Account's number.

      t.string "type" #Brokerage, Credit, Depository, Loan, Mortgage, or Other

      t.string "subtype" # Brokerage, Credit, Depository Loan, Mortage, or Other

      t.timestamps
    end
    add_index("bank_accounts", "item_id")
  end

  def down
    drop_table :bank_accounts
  end
end
