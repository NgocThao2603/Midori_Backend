class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.date :dob, null: false
      t.string :phone
      t.bigint :point, default: 0
      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
