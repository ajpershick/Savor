class CreateAccountBalances < ActiveRecord::Migration[5.1]
  def up
    create_table :account_balances do |t|
      t.integer "user_id" # References the user that the item belongs to

      #item_id is automatically recorded
      t.decimal "account_balance", :default => 0.00, :precision => 15, :scale => 2, :null => false#used to access product data for an Item

      t.timestamps
    end
    add_index("account_balances", "user_id") #what does this do?
  end

  def down
    drop_table :account_balances
  end
end
