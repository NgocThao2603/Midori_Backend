class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.references :lesson, null: false, foreign_key: true
      t.references :vocabulary, foreign_key: true
      t.references :phrase, foreign_key: true
      t.references :example, foreign_key: true
      t.text :question, null: false
      t.column :question_type, "ENUM('choice', 'fill_blank', 'sorting', 'matching')", null: false
      t.json :correct_answers
      t.text :hidden_part
      t.timestamps
    end

    # Ràng buộc: Ít nhất một trong ba FK phải có giá trị
    execute <<-SQL
      ALTER TABLE questions
      ADD CONSTRAINT check_question_source
      CHECK (
        (vocabulary_id IS NOT NULL) +#{' '}
        (phrase_id IS NOT NULL) +#{' '}
        (example_id IS NOT NULL) = 1
      );
    SQL

    # Ràng buộc: correct_answers phải có giá trị nếu question_type != 'choice'
    execute <<-SQL
      ALTER TABLE questions
      ADD CONSTRAINT check_correct_answers
      CHECK (
        question_type = 'choice' OR correct_answers IS NOT NULL
      );
    SQL
  end
end
