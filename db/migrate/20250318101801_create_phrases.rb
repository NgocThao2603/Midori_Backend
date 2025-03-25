class CreatePhrases < ActiveRecord::Migration[8.0]
  def change
    create_table :phrases do |t|
      t.references :vocabulary, null: false, foreign_key: true
      t.string :phrase, null: false
      t.string :main_word, null: false
      t.string :prefix
      t.string :suffix
      t.text :meaning, null: false
      t.timestamps
    end
  end
end
