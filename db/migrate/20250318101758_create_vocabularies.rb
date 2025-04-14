class CreateVocabularies < ActiveRecord::Migration[8.0]
  def change
    create_table :vocabularies do |t|
      t.references :lesson, null: false, foreign_key: true
      t.string :kanji
      t.string :hanviet
      t.string :kana
      t.string :word_type, null: false
      t.timestamps
    end
  end
end
