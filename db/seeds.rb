require 'csv'
require 'json'

# Xóa dữ liệu cũ
Chapter.destroy_all
Lesson.destroy_all
Vocabulary.destroy_all
Meaning.destroy_all
Example.destroy_all

# Định nghĩa danh sách chapters
chapters_data = [
  { title: "Unit 01 - 名詞A", level: "N2", range: (1..100) },
  { title: "Unit 02 - 動詞A", level: "N2", range: (101..220) },
  { title: "Unit 03 - 形容詞A", level: "N2", range: (221..270) },
  { title: "Unit 04 - 名詞B", level: "N2", range: (271..370) },
  { title: "まとめ１ - 複合動詞", level: "N2", range: (371..460) },
  { title: "Unit 05 - カタカナA", level: "N2", range: (461..510) },
  { title: "Unit 06 - 副詞＋接続詞", level: "N2", range: (511..580) },
  { title: "Unit 07 - 名詞C", level: "N2", range: (581..655) },
  { title: "まとめ2 - 同じ漢字を含む名詞", level: "N2", range: (656..680) },
  { title: "Unit 08 - 動詞B", level: "N2", range: (681..790) },
  { title: "Unit 09 - カタカナB", level: "N2", range: (791..840) },
  { title: "Unit 10 - 形容詞B", level: "N2", range: (841..890) },
  { title: "Unit 11 - 名詞D", level: "N2", range: (891..990) },
  { title: "Unit 12 - 動詞C", level: "N2", range: (991..1090) },
  { title: "Unit 13 - 副詞＋連体詞", level: "N2", range: (1091..1160) }
]

# Đọc dữ liệu CSV
csv_path = Rails.root.join('db/data/n2.csv')
csv_data = CSV.read(csv_path, headers: true)

# Tạo dữ liệu
chapters_data.each do |data|
  chapter = Chapter.create!(title: data[:title], level: data[:level])

  vocab_count = data[:range].size
  lesson_size = case chapter.title
  when "Unit 07 - 名詞C" then 7
  when "まとめ2 - 同じ漢字を含む名詞" then (vocab_count.to_f / 15).ceil
  else (vocab_count.to_f / 10).ceil
  end

  words_per_lesson = (vocab_count.to_f / lesson_size).ceil
  vocab_ids = data[:range].to_a

  vocab_ids.each_slice(words_per_lesson).with_index(1) do |lesson_vocab, index|
    lesson = chapter.lessons.create!(title: "Bài #{index}")

    lesson_vocab.each do |vocab_id|
      row = csv_data.find { |r| r["stt"].to_i == vocab_id }
      next unless row

      # Xác định word_type dựa vào title của chapter
      word_type =
        if chapter.title.include?("名詞")
          "Danh từ"
        elsif chapter.title.include?(" 動詞")
          "Động từ"
        elsif chapter.title.include?("形容詞")
          "Tính từ"
        elsif chapter.title.include?("複合動詞")
          "Động từ ghép"
        elsif chapter.title.include?("カタカナ")
          "Katakana"
        elsif chapter.title.include?("副詞＋接続詞")
          "Phó từ/ Liên từ"
        elsif chapter.title.include?("副詞＋連体詞")
          "Phó từ/ Liên thể từ"
        else
          "Khác"
        end

      # Tạo từ vựng
      vocabulary = lesson.vocabularies.create!(
        kanji: row["word"],
        hanviet: row["Sino-Vietnamese"],
        kana: row["furigana"],
        word_type: word_type
      )

      # Xử lý nhiều nghĩa
      meanings = row["meaning"].to_s.split(',').map(&:strip)
      meanings.each do |meaning|
        vocabulary.meanings.create!(meaning: meaning)
      end

      # Tạo ví dụ
      def safe_parse_json(json_str)
        begin
          # Nếu dữ liệu là dạng mảng Ruby, chuyển thành chuỗi JSON
          unless json_str.strip.start_with?('[') && json_str.strip.end_with?(']')
            raise JSON::ParserError, "Không phải định dạng JSON"
          end

          # Chuẩn hóa dấu nháy cong thành nháy thẳng
          json_str = json_str.tr("“”", '"')

          # Chuẩn hóa dấu nháy đơn nếu có
          json_str = json_str.gsub("'", '"')

          # Parse JSON
          JSON.parse(json_str)
        rescue JSON::ParserError => e
          puts "JSON lỗi: #{json_str}, lỗi: #{e.message}"
          []
        end
      end

      # Xử lý dữ liệu example
      examples_data = row["example"].present? ? safe_parse_json(row["example"]) : []
      valid_examples = examples_data.select do |example_pair|
        example_pair.is_a?(Array) && example_pair.size == 2 &&
        !example_pair[0].start_with?("関 ", "類 ", "合 ", "連 ", "対") &&
        example_pair[1].is_a?(String) && !example_pair[1].strip.empty?
      end

      valid_examples.each do |example_pair|
        vocabulary.examples.create!(
          example_sentence: example_pair[0],
          meaning_sentence: example_pair[1]
        )
      end

      # Tạo phrase với main_word đã ghép vào prefix/suffix
      phrases_data = examples_data.select { |pair| pair[0].include?("＿") }
      phrases_data.each do |phrase_pair|
        raw_phrase = phrase_pair[0]
        phrase_meaning = phrase_pair[1].presence || "N/A"

        prefix, suffix = nil, nil

        if raw_phrase.include?("＿")
          parts = raw_phrase.split("＿")
          prefix = parts[0].presence
          suffix = parts[1].presence
        end

        phrase_text = [ prefix, vocabulary.kanji, suffix ].compact.join

        vocabulary.phrases.create!(
          phrase: phrase_text,
          main_word: vocabulary.kanji,
          prefix: prefix,
          suffix: suffix,
          meaning: phrase_meaning
        )
      end
    end
  end
end

puts "Seeding completed!"
