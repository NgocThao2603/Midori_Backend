namespace :audio do
  desc "Generate audio for vocabularies, phrases, examples, tokens under lesson_id = 1"
  task generate_lesson1: :environment do
    firebase_base_url = "https://midori-audio.web.app/audios"
    base_audio_path = "../midori-audio/public/audios"

    # === Vocabularies
    vocabularies = Vocabulary.where("lesson_id >= ?", 113)

    vocabularies.find_each do |vocab|
      unless AudioFile.exists?(vocabulary_id: vocab.id)
        filename = "vocabulary_#{vocab.id}.mp3"
        puts "🔊 Vocab #{vocab.id}: #{vocab.kanji}"
        system("python3 ../crawl/generate_audio.py \"#{vocab.kanji}\" \"#{filename}\"")
        sleep(1)
        AudioFile.create!(
          vocabulary_id: vocab.id,
          audio_url: "#{firebase_base_url}/#{filename}",
          audio_type: "vocab"
        )
      end

      # === Phrases thuộc vocab
      vocab.phrases.find_each do |phrase|
        next if AudioFile.exists?(phrase_id: phrase.id)
        filename = "phrase_#{phrase.id}.mp3"
        puts "🎵 Phrase #{phrase.id}: #{phrase.phrase}"
        system("python3 ../crawl/generate_audio.py \"#{phrase.phrase}\" \"#{filename}\"")
        sleep(1)
        AudioFile.create!(
          phrase_id: phrase.id,
          audio_url: "#{firebase_base_url}/#{filename}",
          audio_type: "phrase"
        )
      end

      # === Examples thuộc vocab
      vocab.examples.find_each do |ex|
        next if AudioFile.exists?(example_id: ex.id)
        filename = "example_#{ex.id}.mp3"
        puts "📘 Example #{ex.id}: #{ex.example_sentence}"
        system("python3 ../crawl/generate_audio.py \"#{ex.example_sentence}\" \"#{filename}\"")
        sleep(1)
        AudioFile.create!(
          example_id: ex.id,
          audio_url: "#{firebase_base_url}/#{filename}",
          audio_type: "example"
        )

        # === ExampleTokens thuộc example
        ex.example_tokens.find_each do |token|
          next if AudioFile.exists?(example_token_id: token.id)
          filename = "example_token_#{token.id}.mp3"
          puts "🔹 Token #{token.id}: #{token.jp_token}"
          system("python3 ../crawl/generate_audio.py \"#{token.jp_token}\" \"#{filename}\"")
          sleep(1)
          AudioFile.create!(
            example_token_id: token.id,
            audio_url: "#{firebase_base_url}/#{filename}",
            audio_type: "example_token"
          )
        end
      end
    end

    puts "\n✅ Done generating audio for lesson_id = 1"
    puts "→ Nhớ chạy: cd ../midori-audio && firebase deploy --only hosting"
  end
end
