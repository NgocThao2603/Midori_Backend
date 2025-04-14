class AddDeviseFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |t|
      ## Devise fields
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      # Xoá cột password_digest nếu có
      t.remove :password_digest if column_exists?(:users, :password_digest)
    end

    add_index :users, :reset_password_token, unique: true
  end
end
