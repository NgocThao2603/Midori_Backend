class CreateUserDailyActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :user_daily_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.date :activity_date, null: false
      t.column :level, "ENUM('N3', 'N2', 'N1')", null: false
      t.boolean :is_studied, default: false, null: false
      t.integer :point_earned, default: 0, null: false

      t.timestamps
    end

    add_index :user_daily_activities, [ :user_id, :activity_date, :level ], unique: true
  end
end
