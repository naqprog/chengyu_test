class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.string :chengyu_jianti,      null: false
      t.string :chengyu_fanti,       null: false
      t.string :pinyin,              null: false
      t.text :mean,                  null: false
      t.string :other_answer_jianti
      t.string :other_answer_fanti
      t.string :other_answer_pinyin
      t.integer :source, default: 0, null: false
      t.integer :level, default: 0,  null: false

      t.timestamps null: false
    end
    add_index :questions, :chengyu_jianti, unique: true
    add_index :questions, :chengyu_fanti,  unique: true
  end
end
