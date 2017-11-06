class CreateUsers < ActiveRecord::Migration[5.1]
  def up
    create_table :users do |t|
      t.string "username", null: false, limit: 30
      t.string "name", null: false
      t.string "password_digest" # The required column name when using the bcrypt encryption gem
      t.string "email", null: false, limit: 255
      t.boolean "admin", null: false, default: false
      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end
