# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#create admin user
User.create(username: 'admintest', name:'admin', password: 'admintest', email: 'admintest@gmail.com', admin: true)

#create vinson user
User.create(username: 'vinsonly', name:'admin', password: 'password', email: 'vinsonly@live.ca', admin: false)
