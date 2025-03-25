class CreateTests < ActiveRecord::Migration[8.0]
  def change
    create_table :tests do |t|
      t.references :lesson, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :total_score, null: false
      t.integer :pass_score, null: false
      t.timestamps
    end
  end
end
