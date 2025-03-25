class CreateExamples < ActiveRecord::Migration[8.0]
  def change
    create_table :examples do |t|
      t.references :vocabulary, null: false, foreign_key: true
      t.text :example_sentence, null: false
      t.text :meaning_sentence, null: false
      t.text :note
      t.timestamps
    end
  end
end
