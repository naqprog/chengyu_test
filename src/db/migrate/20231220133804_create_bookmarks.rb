class CreateBookmarks < ActiveRecord::Migration[7.0]
  def change
    create_table :bookmarks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.boolean :favorite, default: false, null: false
      t.boolean :known, default: false, null: false

      t.timestamps
    end
    add_index :bookmarks, [:user_id, :question_id], unique: true
  end
end
