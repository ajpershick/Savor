# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

categories = [
  "dining",
  "clothing",
  "groceries",
  "automotive",
  "gifts",
  "entertainment",
  "recreation",
  "transit",
  "utilities",
  "maintenance",
  "medical",
  "debt",
  "luxury",       #leisure?
  "education",
  "pets",
  "insurance",
  "supplies",
  "housing",
  "charity",
  "savings",
  "travel",
  "personal care",
  "taxes",
  "miscellaneous",
]

(0..categories.length - 1).each do |i|
  Transaction.create(
    user_id: 1,
    amount: (rand * 1000).round(2),
    date: Date.today - 1,
    category: categories[i],
    location_name: (0...3).map { (97 + rand(26)).chr }.join,
    transaction_type: "place",
    location: false,
    unique_id: "1")
end

(0..2000).each do
  Transaction.create(
    user_id: 1,
    amount: (rand * 1000).round(2),
    date: Date.today - 2 - rand(900),
    category: categories[rand(0..categories.length - 1)],
    location_name: (0...3).map { (97 + rand(26)).chr }.join,
    transaction_type: "place",
    location: false,
    unique_id: "1")
end

user = User.new
user.id = 1
user.username = "testing"
user.name = "Test"
user.password = "testing"
user.email = "test@test.ca"
user.admin = false
user.save

admin = User.new
admin.id = 2
admin.username = "admintest"
admin.name = "Admin"
admin.password = "admintest"
admin.email = "admin@test.ca"
admin.admin = true
admin.save

balance = AccountBalance.new
balance.user_id = 1
balance.bank_balance = 0 #add up balances in bank account, once user has created item
balance.cash_balance = 9001.00
balance.total_balance = balance.cash_balance + balance.bank_balance
balance.save
