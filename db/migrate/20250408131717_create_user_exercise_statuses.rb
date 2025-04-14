class CreateUserExerciseStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :user_exercise_statuses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.string :exercise_type
      t.boolean :done, default: false
      t.datetime :done_at

      t.timestamps
    end

    add_index :user_exercise_statuses, [:user_id, :lesson_id, :exercise_type], unique: true, name: "index_user_lesson_exercise_unique"
  end
end
