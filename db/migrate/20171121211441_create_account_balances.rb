class CreateAccountBalances < ActiveRecord::Migration[5.1]
  def up
    create_table :account_balances do |t|
      t.integer "user_id" # References the user that the item belongs to

      #balance in bank account
      t.decimal "bank_balance", :default => 0.00, :precision => 15, :scale => 2
      #balance in cash
      t.decimal "cash_balance", :default => 0.00, :precision => 15, :scale => 2
      #sum of total and cash balances
      t.decimal "total_balance", :default => 0.00, :precision => 15, :scale => 2




      t.timestamps
    end
    add_index("account_balances", "user_id") #what does this do?
  end

  def down
    drop_table :account_balances
  end
end
