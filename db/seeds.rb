require 'csv'
require 'json'

# # Xóa dữ liệu cũ
# Chapter.destroy_all
# Lesson.destroy_all
# Vocabulary.destroy_all
# Meaning.destroy_all
# Example.destroy_all

# Định nghĩa danh sách chapters
chapters_data = [
  # N2 chapters
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
  { title: "Unit 13 - 副詞＋連体詞", level: "N2", range: (1091..1160) },

  # N3 chapters
  { title: "Unit 01 - 名詞A", level: "N3", range: (1..120) },
  { title: "Unit 02 - 動詞A", level: "N3", range: (121..220) },
  { title: "まとめ - 連用名詞", level: "N3", range: (221..258) },
  { title: "Unit 03 - 形容詞A", level: "N3", range: (259..298) },
  { title: "まとめ - イ形容詞＋まる／める", level: "N3", range: (299..310) },
  { title: "Unit 04 - 名詞B", level: "N3", range: (311..410) },
  { title: "Unit 05 - 動詞B", level: "N3", range: (411..510) },
  { title: "Unit 06 - カタカナA", level: "N3", range: (511..550) },
  { title: "Unit 07 - 形容詞B", level: "N3", range: (551..590) },
  { title: "Unit 08 - 副詞A ", level: "N3", range: (591..635) },
  { title: "Unit 09 - 名詞C", level: "N3", range: (636..715) },
  { title: "Unit 10 - 動詞C", level: "N3", range: (716..795) },
  { title: "Unit 11 - カタカナB", level: "N3", range: (796..835) },
  { title: "まとめ - 料理の動詞", level: "N3", range: (836..845) },
  { title: "Unit 12 - 副詞B、連体詞・接続詞", level: "N3", range: (846..880) },

  # N1 chapters
  { title: "Unit 01 - 名詞A", level: "N1", range: (1..100) },
  { title: "Unit 02 - 動詞A", level: "N1", range: (101..190) },
  { title: "Unit 03 - 形容詞A", level: "N1", range: (191..280) },
  { title: "Unit 04 - 名詞B", level: "N1", range: (281..380) },
  { title: "Unit 05 - 複合動詞", level: "N1", range: (381..480) },
  { title: "Unit 06 - カタカナA", level: "N1", range: (481..530) },
  { title: "Unit 07 - 副詞A＋接続詞", level: "N1", range: (531..600) },
  { title: "Unit 08 - 名詞C", level: "N1", range: (601..700) },
  { title: "Unit 09 - 動詞B", level: "N1", range: (701..800) },
  { title: "Unit 10 - カタカナB", level: "N1", range: (801..850) },
  { title: "Unit 11 - 形容詞B", level: "N1", range: (851..930) },
  { title: "Unit 12 - 名詞D", level: "N1", range: (931..1020) },
  { title: "Unit 13 - 動詞C", level: "N1", range: (1021..1110) },
  { title: "Unit 14 - 副詞B＋連体詞", level: "N1", range: (1111..1170) }
]

# Đọc dữ liệu CSV
csv_path = Rails.root.join('db/data/n1.csv')
csv_data = CSV.read(csv_path, headers: true)

def create_phrase_with_translation(phrase_text, vocabulary, prefix, suffix, phrase_type)
  # Dịch phrase sang tiếng Việt
  translated_meaning = HandleData::TranslationService.translate_to_vietnamese(phrase_text)
  furigana = HandleData::FuriganaService.generate_furigana(phrase_text)
  
  # Tạo phrase
  vocabulary.phrases.create!(
    phrase: phrase_text,
    main_word: vocabulary.kanji,
    prefix: prefix,
    suffix: suffix,
    meaning: translated_meaning,
    furigana: furigana,
    phrase_type: phrase_type
  )
  
  puts "  📝 Phrase: #{phrase_text} -> #{translated_meaning}"
  
  # Thêm delay nhỏ để tránh rate limit
  sleep(0.2)
end

# Tạo dữ liệu
chapters_data.each do |data|
  chapter = Chapter.find_or_initialize_by(title: data[:title], level: data[:level])
  chapter.save! unless chapter.persisted?

  vocab_count = data[:range].size
  lesson_size = case chapter.title
  # N2
  when "Unit 07 - 名詞C" then 7
  when "まとめ2 - 同じ漢字を含む名詞" then (vocab_count.to_f / 15).ceil

  # N3
  when "まとめ - イ形容詞＋まる／める" then 1
  when "Unit 12 - 副詞B、連体詞・接続詞" then 3
  when "Unit 08 - 副詞A" then (vocab_count.to_f / 15).ceil

  # N1
  else (vocab_count.to_f / 10).ceil
  end

  words_per_lesson = (vocab_count.to_f / lesson_size).ceil
  vocab_ids = data[:range].to_a

  vocab_ids.each_slice(words_per_lesson).with_index(1) do |lesson_vocab, index|
    lesson = chapter.lessons.find_or_initialize_by(title: "Bài #{index}")
    lesson.save! unless lesson.persisted?

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
        elsif chapter.title.include?("副詞B、連体詞・接続詞")
          "Phó từ/ Liên (thể ) từ"
        elsif [ "副詞＋接続詞", "＋接続詞" ].any? { |phrase| chapter.title.include?(phrase) }
          "Phó từ/ Liên từ"
        elsif [ "副詞＋連体詞", "＋連体詞" ].any? { |phrase| chapter.title.include?(phrase) }
          "Phó từ/ Liên thể từ"
        elsif chapter.title.include?("副詞")
          "Phó từ"
        else
          "Khác"
        end

      PHRASE_TYPES = [ "関", "類", "合", "連", "対", "名", "慣" ]

      # Tạo từ vựng
      # vocabulary = lesson.vocabularies.create!(
      #   stt: row["stt"].to_i,
      #   kanji: row["word"],
      #   hanviet: row["Sino-Vietnamese"],
      #   kana: row["furigana"],
      #   word_type: word_type
      # )

      vocabulary = lesson.vocabularies.find_or_initialize_by(stt: row["stt"].to_i)
      vocabulary.assign_attributes(
        kanji: row["word"],
        hanviet: row["Sino-Vietnamese"],
        kana: row["furigana"],
        word_type: word_type
      )
      vocabulary.save!

      # Xử lý nhiều nghĩa
      meanings = row["meaning"].to_s.split(',').map(&:strip)
      meanings.each do |meaning|
        unless vocabulary.meanings.exists?(meaning: meaning)
          vocabulary.meanings.create!(meaning: meaning)
        end
      end

      # Tạo ví dụ
      def safe_parse_json(json_str)
        begin
          # Nếu dữ liệu là dạng mảng Ruby, chuyển thành chuỗi JSON
          unless json_str.strip.start_with?('[') && json_str.strip.end_with?(']')
            raise JSON::ParserError, "Không phải định dạng JSON"
          end

          # Chuẩn hóa dấu nháy cong thành nháy thẳng
          json_str = json_str.tr("""", '"')

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
        !example_pair[0].start_with?("関 ", "類 ", "合 ", "連 ", "対 ", "名 ", "慣 ") &&
        !example_pair[0].include?("＿") &&
        example_pair[1].is_a?(String) && !example_pair[1].strip.empty?
      end

      # valid_examples.each do |example_pair|
      #   clean_jp = example_pair[0].sub(/^\d+\.\s*/, "")

      #   example = vocabulary.examples.create!(
      #     example_sentence: clean_jp,
      #     meaning_sentence: example_pair[1]
      #   )

      #   tokens = HandleData::TokenizerService.tokenize(example.example_sentence)
      #   tokens.each do |token|
      #     next if token[:surface].blank?
      #     ExampleToken.create!(
      #       example_id: example.id,
      #       token_index: token[:index],
      #       jp_token: token[:surface],
      #       vn_token: HandleData::TranslationService.translate_to_vietnamese(token[:surface])
      #     )
      #   end
      # end

      valid_examples.each do |example_pair|
        clean_jp = example_pair[0].sub(/^\d+\.\s*/, "")
        meaning_jp = example_pair[1]

        example = vocabulary.examples.find_or_initialize_by(example_sentence: clean_jp)
        example.meaning_sentence = meaning_jp
        example.save!

        unless example.example_tokens.exists?
          tokens = HandleData::TokenizerService.tokenize(example.example_sentence)
          tokens.each do |token|
            next if token[:surface].blank?

            example.example_tokens.create!(
              token_index: token[:index],
              jp_token: token[:surface],
              vn_token: HandleData::TranslationService.translate_to_vietnamese(token[:surface])
            )
          end
        end
      end

      # Xử lý phrases - PHƯƠNG PHÁP MỚI
      def process_phrases(examples_data, vocabulary)
        phrases_data = examples_data.select { |pair| 
          pair.is_a?(Array) && pair.size == 2 &&
          PHRASE_TYPES.any? { |type| pair[0].start_with?("#{type} ") }
        }
        
        phrases_data.each do |phrase_pair|
          raw_phrase = phrase_pair[0]
          phrase_meaning = phrase_pair[1].presence || ""

          # Tách phrase_type
          detected_type = nil
          PHRASE_TYPES.each do |type|
            if raw_phrase.start_with?("#{type} ")
              detected_type = type
              raw_phrase = raw_phrase.sub("#{type} ", "")
              break
            end
          end

          process_by_type(raw_phrase, phrase_meaning, detected_type, vocabulary)
        end
      end

      def process_by_type(raw_phrase, phrase_meaning, phrase_type, vocabulary)
        case phrase_type
        when "関", "類", "対"
          # Simple pattern - chỉ tách bằng dấu phẩy
          process_simple_pattern(raw_phrase, phrase_meaning, phrase_type, vocabulary)
        when "合", "連"
          # Complex pattern - có thể có ＿, <=> và ngoặc đơn
          process_complex_pattern(raw_phrase, phrase_meaning, phrase_type, vocabulary)
        end
      end

      def process_simple_pattern(raw_phrase, phrase_meaning, phrase_type, vocabulary)
        # Tách bằng dấu phẩy (cả , và 、)
        phrases = raw_phrase.split(/[,、]/).map(&:strip)
        
        phrases.each do |phrase|
          next if phrase.empty?
          
          create_phrase_with_translation(
            phrase,
            vocabulary,
            nil,
            nil,
            phrase_type
          )
        end
      end

      def process_complex_pattern(raw_phrase, phrase_meaning, phrase_type, vocabulary)
        # Xử lý pattern có ngoặc đơn trước
        if raw_phrase.include?("（") && raw_phrase.include?("）")
          process_parentheses_pattern(raw_phrase, phrase_meaning, phrase_type, vocabulary)
        else
          # Tách bằng dấu phẩy (cả , và 、) trước
          phrase_parts = raw_phrase.split(/[,、]/).map(&:strip)
          
          phrase_parts.each do |phrase_part|
            next if phrase_part.empty?
            
            if phrase_part =~ /＜＝＞|<=>/ || phrase_part.include?("・")
              process_contrast_phrase(phrase_part, phrase_meaning, phrase_type, vocabulary)
            elsif phrase_part.include?("＿")
              process_underscore_phrase(phrase_part, phrase_meaning, phrase_type, vocabulary)
            else
              # Không có ＿ - xử lý như simple pattern
              create_phrase_with_translation(
                phrase_part,
                vocabulary,
                nil,
                nil,
                phrase_type
              )
            end
          end
        end
      end

      def process_parentheses_pattern(raw_phrase, phrase_meaning, phrase_type, vocabulary)
        # Xử lý pattern có ngoặc đơn - VD: "＿子（遺伝子操作、遺伝子治療、遺伝子組み換え）"
        
        # Tách phần trước và trong ngoặc
        paren_start = raw_phrase.index("（")
        paren_end = raw_phrase.index("）")
        
        if paren_start && paren_end && paren_start < paren_end
          base_part = raw_phrase[0...paren_start].strip
          inside_paren = raw_phrase[(paren_start + 1)...paren_end].strip
          
          # Tạo phrase cho phần base
          if base_part.include?("＿")
            parts = base_part.split("＿")
            prefix = parts[0].presence
            suffix = parts[1].presence
            
            phrase_text = [prefix, vocabulary.kanji, suffix].compact.join
            create_phrase_with_translation(
              phrase_text,
              vocabulary,
              prefix,
              suffix,
              phrase_type
            )
          end
          
          # Xử lý phần trong ngoặc - tách bằng dấu phẩy
          inside_parts = inside_paren.split(/[,、]/).map(&:strip)
          inside_parts.each do |part|
            next if part.empty?
            
            create_phrase_with_translation(
              part,
              vocabulary,
              nil,
              nil,
              phrase_type
            )
          end
        end
      end

      def process_contrast_phrase(phrase_part, phrase_meaning, phrase_type, vocabulary)
        # Xử lý pattern có <=> hoặc ・
        if phrase_part.include?("＿")
          if phrase_part =~ /＜＝＞|<=>/
            # Có ＿ và <=> 
            contrast_parts = phrase_part.split(/＜＝＞|<=>/).map(&:strip)
            
            if contrast_parts.length == 2
              first_part = contrast_parts[0]
              second_part = contrast_parts[1]
              
              # Case 1: ＿ ở đầu phần đầu - VD: "＿が早い＜＝＞遅い"
              if first_part.start_with?("＿") && !second_part.include?("＿")
                parts = first_part.split("＿")
                prefix = parts[0].presence
                first_suffix = parts[1].presence
                
                # Tạo phrase đầu tiên
                if first_suffix
                  phrase1 = [prefix, vocabulary.kanji, first_suffix].compact.join
                  create_phrase_with_translation(
                    phrase1,
                    vocabulary,
                    prefix,
                    first_suffix,
                    phrase_type
                  )
                end
                
                # Xử lý phần sau <=>
                connector = extract_connector_from_suffix(first_suffix)
                second_suffix = connector ? "#{connector}#{second_part}" : second_part
                
                phrase2 = [prefix, vocabulary.kanji, second_suffix].compact.join
                create_phrase_with_translation(
                  phrase2,
                  vocabulary,
                  prefix,
                  second_suffix,
                  phrase_type
                )
              else
                # Case 2: Cả hai phần đều có ＿ hoặc pattern phức tạp
                # VD: "好＿＜＝＞不＿" hoặc "＿が豊だ＜＝＞＿に乏しい"
                [first_part, second_part].each do |part|
                  if part.include?("＿")
                    parts = part.split("＿")
                    prefix = parts[0].presence
                    suffix = parts[1].presence
                    
                    phrase_text = [prefix, vocabulary.kanji, suffix].compact.join
                    create_phrase_with_translation(
                      phrase_text,
                      vocabulary,
                      prefix,
                      suffix,
                      phrase_type
                    )
                  else
                    # Phần không có ＿
                    create_phrase_with_translation(
                      part,
                      vocabulary,
                      nil,
                      nil,
                      phrase_type
                    )
                  end
                end
              end
            end
          elsif phrase_part.include?("・")
            # Có ＿ và ・ - VD: "＿が上がる・をあげる"
            dot_parts = phrase_part.split("・").map(&:strip)
            
            # Tìm phần có ＿ để lấy prefix
            base_prefix = nil
            dot_parts.each do |part|
              if part.include?("＿")
                parts = part.split("＿")
                base_prefix = parts[0].presence
                break
              end
            end
            
            dot_parts.each do |part|
              if part.include?("＿")
                # Phần có ＿ - xử lý bình thường
                parts = part.split("＿")
                prefix = parts[0].presence
                suffix = parts[1].presence
                
                phrase_text = [prefix, vocabulary.kanji, suffix].compact.join
                create_phrase_with_translation(
                  phrase_text,
                  vocabulary,
                  prefix,
                  suffix,
                  phrase_type
                )
              else
                # Phần không có ＿ - thêm từ gốc vào
                # VD: "をあげる" → "能力をあげる"
                phrase_text = [base_prefix, vocabulary.kanji, part].compact.join
                create_phrase_with_translation(
                  phrase_text,
                  vocabulary,
                  base_prefix,
                  part,
                  phrase_type
                )
              end
            end
          else
            # Chỉ có ＿ - xử lý bình thường
            process_underscore_phrase(phrase_part, phrase_meaning, phrase_type, vocabulary)
          end
        else
          # Không có ＿
          if phrase_part =~ /＜＝＞|<=>/
            # Không có ＿ nhưng có <=> - VD: "好況＜＝＞不況"
            contrasts = phrase_part.split(/＜＝＞|<=>/).map(&:strip)
            contrasts.each do |contrast|
              next if contrast.empty?
              create_phrase_with_translation(
                contrast,
                vocabulary,
                nil,
                nil,
                phrase_type
              )
            end
          elsif phrase_part.include?("・")
            # Không có ＿ nhưng có ・
            dot_parts = phrase_part.split("・").map(&:strip)
            dot_parts.each do |part|
              next if part.empty?
              create_phrase_with_translation(
                part,
                vocabulary,
                nil,
                nil,
                phrase_type
              )
            end
          end
        end
      end

      def extract_connector_from_suffix(suffix)
        # Trích xuất trợ từ từ đầu suffix
        return nil unless suffix
        
        connectors = ["が", "を", "に", "で", "から", "まで", "と", "や", "の", "は", "も", "だけ", "ばかり"]
        connectors.each do |conn|
          if suffix.start_with?(conn)
            return conn
          end
        end
        nil
      end

      def process_underscore_phrase(phrase_part, phrase_meaning, phrase_type, vocabulary)
        # Xử lý pattern có ＿ nhưng không có <=> hoặc ・
        # VD: "＿経験", "＿を送る"

        parts = phrase_part.split("＿")
        return unless parts.length == 2

        prefix = parts[0].presence
        suffix = parts[1].presence

        phrase_text = [ prefix, vocabulary.kanji, suffix ].compact.join

        create_phrase_with_translation(
          phrase_text,
          vocabulary,
          prefix,
          suffix,
          phrase_type
        )
      end

      # Gọi hàm xử lý phrases
      process_phrases(examples_data, vocabulary)
    end
  end
end

# ==========================================================================
Lesson.find_each do |lesson|
# Lesson.joins(:chapter).where(chapters: { level: "N1" }).find_each do |lesson|
  begin
    puts "Processing Lesson ID: #{lesson.id}"

    AutoGenQuestion::MatchQuestionGeneratorService.new(lesson).call
    AutoGenQuestion::ChoiceQuestionGeneratorService.new(lesson).call
    AutoGenQuestion::SortQuestionGeneratorService.new(lesson).call
    AutoGenQuestion::FillBlankQuestionGeneratorService.new(lesson).call

    puts "Generated questions for Lesson ID: #{lesson.id}"
  rescue => e
    puts "Skipped Lesson ID: #{lesson.id} due to error: #{e.message}"
  end
end
# ==========================================================================

Lesson.find_each do |lesson|
  Test.create!(
    lesson: lesson,
    title: "Bài test 1",
    duration_minutes: 20
  )
end

puts "Seeding completed!"
