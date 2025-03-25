class CreateTestQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :test_questions do |t|
      t.references :test_attempt, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :score, null: false, default: 1
      t.timestamps
    end
  end
end
