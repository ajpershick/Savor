class CreateIncomes < ActiveRecord::Migration[5.1]
  def up
    create_table :incomes do |t|

      t.integer "user_id" # References the user that the income entry belongs to
      #amount of income received in the income entry
      t.decimal "income_amount", :default => 0.00, :precision => 15, :scale => 2
      #Where the income came from
      t.string "source", null:false, default:"miscellaneous"
      t.date "date", null:false
      t.timestamps
    end
    add_index("incomes", "user_id") #what does this do?s
  end

  def down
    drop_table :incomes
  end
end
