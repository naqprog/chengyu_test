class CreateResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :responses do |t|
      t.references :user, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :test_format, default: 0, null: false
      t.boolean :correct, default: false, null: false

      t.timestamps
    end
  end
end
