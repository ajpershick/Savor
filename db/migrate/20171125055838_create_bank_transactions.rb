class CreateBankTransactions < ActiveRecord::Migration[5.1]
  def up
    create_table :bank_transactions do |t|
      t.integer "user_id" # References the user that the item belongs to

      t.string "item_id" #The unique of the item that this account belongs to

      t.integer "bank_account_id" #the database primary key for the bank_account_id record that this record is associated to

      t.string "account_id" #The if od the account in which this transaction occurred
                            #The unique ID of the account
                            # In some instances, account ID's may change

      t.string "transaction_id" #The unique id of the transaction

      t.string "category", array: true #A hierarachical array of the categories to which this transaction belongs.

      t.string "category_id" #The id of the category to which this transaction belongs

      t.string "transaction_type" #Place, digital, special, or unresolved

      t.decimal "amount", :default => 0.00, :precision => 15, :scale => 2
        #The settled dollar value.
        #Positive values when money moves out of the account
        #  purchases
        #Negative values when money moves into the account
        #  Credit card payments, direct deposits, refunds

      t.date "date" #For pending transactions, Plaid returns the date the transaction occurred;
                    #for posted transactions, Plaid returns the date the transaction posts.
                    #Both dates are returned in an ISO8601 format (YYYY-MM-DD)


      t.boolean "location_bool" #indicates whether there is available location data

      t.string "location", array: true
        # Detailed merchant location data including address, city, state, zip, lat, and lon, where available
        #   Address
        #   City
        #   State
        #   Zip
        #   Lat (latitude)
        #   Lon (longitude)


      t.string "name" #The name of the business

      t.boolean "pending" #When true, identifies the transaction as pending or unsettled.
                          #Pending transaction details (name, type, amount) may change before they are settled.

      t.string "pending_transaction_id" #The id of a posted transaction’s associated pending tranasction--where applicable.

      t.timestamps
    end
    add_index("bank_transactions", "bank_account_id")
  end

  def down
    drop_table :bank_transactions
  end
end
