class CreateMeanings < ActiveRecord::Migration[8.0]
  def change
    create_table :meanings do |t|
      t.references :vocabulary, null: false, foreign_key: true
      t.text :meaning, null: false
      t.timestamps
    end
  end
end
