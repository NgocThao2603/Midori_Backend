class ChangeEndTimeNullableInTestAttempts < ActiveRecord::Migration[8.0]
  def change
    change_column_null :test_attempts, :end_time, true
  end
end
