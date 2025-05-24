class UpdateTestsAddDurationAndDefaults < ActiveRecord::Migration[8.0]
  def change
    add_column :tests, :duration_minutes, :integer, default: 30, null: false

    change_column_default :tests, :total_score, from: nil, to: 100
    change_column_default :tests, :pass_score, from: nil, to: 75
  end
end
