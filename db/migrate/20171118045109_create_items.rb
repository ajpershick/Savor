class CreateItems < ActiveRecord::Migration[5.1]
  def up
    create_table :items, id: false do |t|
      t.integer "user_id" # References the user that the item belongs to
      t.string "item_id"
      #item_id is automatically recorded
      t.string "access_token" #used to access product data for an Item

      t.timestamps
    end
    add_index("items", "user_id") #what does this do?
  end

  def down
    drop_table :items
  end
end
