# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171125055838) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_balances", force: :cascade do |t|
    t.integer "user_id"
    t.decimal "bank_balance", precision: 15, scale: 2, default: "0.0"
    t.decimal "cash_balance", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_balance", precision: 15, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_account_balances_on_user_id"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.integer "user_id"
    t.string "item_id"
    t.string "account_id"
    t.decimal "available_balance", precision: 15, scale: 2, default: "0.0"
    t.decimal "current_balance", precision: 15, scale: 2, default: "0.0"
    t.string "name"
    t.string "mask"
    t.string "official_name"
    t.string "account_type"
    t.string "account_subtype"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_bank_accounts_on_item_id"
  end

  create_table "bank_transactions", force: :cascade do |t|
    t.integer "user_id"
    t.string "item_id"
    t.string "bank_account_id"
    t.string "account_id"
    t.string "transaction_id"
    t.string "category", array: true
    t.string "category_id"
    t.string "transaction_type"
    t.decimal "amount", precision: 15, scale: 2, default: "0.0"
    t.date "date"
    t.boolean "location_bool"
    t.string "location", array: true
    t.string "name"
    t.boolean "pending"
    t.string "pending_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_bank_transactions_on_bank_account_id"
  end

  create_table "incomes", force: :cascade do |t|
    t.integer "user_id"
    t.decimal "income_amount", precision: 15, scale: 2, default: "0.0"
    t.string "source", default: "miscellaneous", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_incomes_on_user_id"
  end

  create_table "items", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.string "item_id"
    t.string "access_token"
    t.string "institution_id"
    t.string "institution_name"
    t.string "available_products", array: true
    t.string "billed_products", array: true
    t.decimal "total_account_balance", precision: 15, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "user_id"
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.date "date", null: false
    t.string "category", default: "miscellaneous", null: false
    t.string "transaction_type", null: false
    t.string "unique_id", null: false
    t.boolean "location", default: false, null: false
    t.string "location_name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "latitude"
    t.string "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", limit: 30, null: false
    t.string "name", null: false
    t.string "password_digest"
    t.string "email", limit: 255, null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "widgets", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "stock"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
