class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.references :user, index: { unique: true }, foreign_key: true
      t.integer :letter_kind, default: 0, null: false
      t.integer :test_format, default: 0, null: false
      t.integer :test_kind, default: 0, null: false

      t.timestamps
    end
  end
end
