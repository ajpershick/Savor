# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

categories = ["food", "clothing", "groceries", "gas"]

(0..1000).each do
  Transaction.create(
    user_id: 1,
    amount: (rand * 1000).round(2),
    date: Date.today-rand(1000),
    category: categories[rand(0..3)],
    location_name: (0...3).map { (97 + rand(26)).chr }.join,
    transaction_type: "place",
    location: false,
    unique_id: "1")
end
