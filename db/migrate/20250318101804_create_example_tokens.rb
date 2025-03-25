class CreateExampleTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :example_tokens do |t|
      t.references :example, null: false, foreign_key: true
      t.integer :token_index, null: false
      t.string :jp_token, null: false
      t.string :vn_token
      t.timestamps
    end
  end
end
