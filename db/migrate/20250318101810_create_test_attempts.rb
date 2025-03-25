class CreateTestAttempts < ActiveRecord::Migration[8.0]
  def change
    create_table :test_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :test, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :score
      t.column :status, "ENUM('in_progress', 'completed')", null: false, default: 'in_progress'
      t.timestamps
    end
  end
end
