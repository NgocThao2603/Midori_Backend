class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.string :title, null: false
      t.references :chapter, null: false, foreign_key: true
      t.timestamps
    end
  end
end
