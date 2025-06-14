class AddFuriganaAndPhraseTypeToPhrases < ActiveRecord::Migration[8.0]
  def change
    add_column :phrases, :furigana, :string
    add_column :phrases, :phrase_type, :string
  end
end
