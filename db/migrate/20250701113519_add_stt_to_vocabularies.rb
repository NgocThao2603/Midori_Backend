class AddSttToVocabularies < ActiveRecord::Migration[8.0]
  def change
    add_column :vocabularies, :stt, :integer, null: true
  end
end
