class CreateAudioFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :audio_files do |t|
      t.references :vocabulary, foreign_key: true
      t.references :phrase, foreign_key: true
      t.references :example, foreign_key: true
      t.references :example_token, foreign_key: true

      t.string :audio_url, null: false
      t.timestamps

      t.column :audio_type, "ENUM('vocab', 'phrase', 'example', 'example_token')", null: false
    end

    # Ràng buộc: chỉ 1 trong 4 FK được gán (tức đúng 1 mối liên kết)
    execute <<-SQL
      ALTER TABLE audio_files
      ADD CONSTRAINT check_audio_source
      CHECK (
        (vocabulary_id IS NOT NULL) +#{' '}
        (phrase_id IS NOT NULL) +#{' '}
        (example_id IS NOT NULL) +#{' '}
        (example_token_id IS NOT NULL) = 1
      );
    SQL
  end
end
