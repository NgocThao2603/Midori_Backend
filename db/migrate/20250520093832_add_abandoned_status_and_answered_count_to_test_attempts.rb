class AddAbandonedStatusAndAnsweredCountToTestAttempts < ActiveRecord::Migration[8.0]
  def up
    # 1. Thêm giá trị 'abandoned' vào enum status (phải dùng execute vì MySQL enum)
    execute <<-SQL
      ALTER TABLE test_attempts
      MODIFY status ENUM('in_progress', 'completed', 'abandoned') DEFAULT 'in_progress' NOT NULL;
    SQL

    add_column :test_attempts, :answered_count, :integer, default: 0, null: false
  end

  def down
    remove_column :test_attempts, :answered_count

    execute <<-SQL
      ALTER TABLE test_attempts
      MODIFY status ENUM('in_progress', 'completed') DEFAULT 'in_progress' NOT NULL;
    SQL
  end
end
