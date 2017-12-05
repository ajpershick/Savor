class CreateItems < ActiveRecord::Migration[5.1]
  def up
    create_table :items, id: false do |t|
      t.integer "user_id" # References the user that the item belongs to
      t.string "item_id" #unique item_id generated from plaid
      #item_id is automatically recorded

      t.string "access_token" #used to access product data for an Item

      t.string "institution_id" #The financial institution associated with the Account. (TD, BMO, RBC, etc.)

      t.string "institution_name"

      t.string "available_products", array: true

      t.string "billed_products", array: true;

      t.decimal "total_account_balance", :default => 0.00, :precision => 15, :scale => 2


      t.timestamps
    end
    add_index("items", "user_id") #what does this do?
  end

  def down
    drop_table :items
  end
end
