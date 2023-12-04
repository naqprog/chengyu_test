require 'csv'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create!(
   email: 'test@example.com',
   password: 'password',
   role: 1
)

CSV.foreach('db/seeds_data/question.csv', headers: true) do |question|
  Question.create(
   # idは不要だから[0]は無視
    :chengyu_jianti => question[1], 
    :chengyu_fanti => question[2], 
    :pinyin => question[3], 
    :mean => question[4], 
    :source => question[5], 
    :level => question[6], 
    :created_at => question[7], 
    :updated_at => question[8], 
  )
end
