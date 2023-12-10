class CreateSynonyms < ActiveRecord::Migration[7.0]
  def change
    create_table :synonyms do |t|
      t.references :question, null: false, foreign_key: true
      t.references :question_another, null: false, foreign_key: { to_table: :questions }

      t.timestamps
      t.index [:question_id, :question_another_id], unique: true
    end
  end
end
