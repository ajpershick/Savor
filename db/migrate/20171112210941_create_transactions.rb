class CreateTransactions < ActiveRecord::Migration[5.1]
  def up
    create_table :transactions do |t|
      t.integer "user_id" # References the user that the transaction belongs to

      t.decimal "amount", precision: 8, scale: 2, null:false
      t.date "date", null:false
      t.string "category", null:false, default:"Unknown"
      t.string "transaction_type", null:false
      t.string "unique_id", null:false

      t.boolean "location", null:false, default: false
      t.string "location_name"
      t.string "address"
      t.string "city"
      t.string "state"
      t.string "zip"
      t.string "latitude"
      t.string "longitude"

      t.timestamps
    end
    add_index("transactions", "user_id")
  end

  def down
    drop_table :transactions
  end
end
