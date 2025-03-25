class CreateChapters < ActiveRecord::Migration[8.0]
  def change
    create_table :chapters do |t|
      t.string :title, null: false
      t.column :level, "ENUM('N3', 'N2', 'N1')", null: false
      t.timestamps
    end
  end
end
