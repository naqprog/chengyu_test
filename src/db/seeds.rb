require 'csv'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create!(
  :email => 'testj@example.com',
  :password => 'password',
  :role => Constants.role.admin
)

Setting.create!(
  :user_id => 1,
  :letter_kind => Constants.letter_kind.jiantizi,
  :test_format => 0,
  :test_kind => 0
)

User.create!(
  :email => 'testf@example.com',
  :password => 'password',
  :role => Constants.role.admin
)

Setting.create!(
  :user_id => 2,
  :letter_kind => Constants.letter_kind.fantizi,
  :test_format => 0,
  :test_kind => 1
)

CSV.foreach('db/seeds_data/question.csv', headers: true) do |question|
  Question.create(
   # idは不要だから[0]は無視
    :chengyu_jianti => question[1], 
    :chengyu_fanti => question[2], 
    :pinyin => question[3], 
    :mean => question[4],
    :note => question[5],
    :other_answer_jianti => question[6], 
    :other_answer_fanti => question[7], 
    :other_answer_pinyin => question[8], 
    :source => question[9], 
    :level => question[10], 
    :created_at => question[11], 
    :updated_at => question[12]
  )
end

CSV.foreach('db/seeds_data/synonym.csv', headers: true) do |synonym|
  Synonym.create(
    # idは不要だから[0]は無視
    :question_id => synonym[1], 
    :question_another_id => synonym[2], 
    :created_at => synonym[3], 
    :updated_at => synonym[4]
  )  
end
