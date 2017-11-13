# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



(0..1000).each do
  Transaction.create(user_id: 1, amount: 12.3, date: Date.today-rand(1000), category: "test", transaction_type: "place", location: false, unique_id: "1")
end
