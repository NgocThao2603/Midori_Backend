# require "natto"
# require_relative "furigana_service"

# module HandleData
#   class TokenizerService
#     def self.tokenize(text)
#       nm = Natto::MeCab.new
#       tokens = []
#       buffer = ""
#       buffer_furigana = ""
#       index = 0

#       nm.parse(text) do |n|
#         next if n.is_eos?

#         surface = n.surface.strip
#         next if surface.empty? || %w[「 」].include?(surface)

#         features = n.feature.split(",")
#         pos = features[0]
#         surface_pos = features[1]
#         reading = features[7]
#         furigana = if reading && reading != "*" && !reading.empty?
#                      HandleData::FuriganaService.katakana_to_hiragana(reading)
#                    else
#                      surface
#                    end

#         if %w[な の].include?(surface) && buffer.present?
#           # Gộp "な", "の" vào token trước trong buffer
#           buffer += surface
#           buffer_furigana += furigana
#         elsif pos == "記号" && %w[、 。].include?(surface) && buffer.present?
#           # Gộp dấu câu vào token trước
#           buffer += surface
#           buffer_furigana += furigana
#         elsif pos == "助詞" || pos == "助動詞" || surface.match?(/^[ぁぃぅぇぉゃゅょっー]+$/)
#           # Gộp cụm trợ động từ/phụ tố tiếp vào buffer
#           buffer += surface
#           buffer_furigana += furigana
#         else
#           # Flush buffer nếu có
#           if buffer.present?
#             tokens << {
#               index: index,
#               surface: buffer,
#               furigana: buffer_furigana,
#               pos: "compound"
#             }
#             index += 1
#           end

#           # Khởi tạo buffer mới
#           buffer = surface
#           buffer_furigana = furigana
#         end
#       end

#       # Flush buffer lần cuối
#       if buffer.present?
#         tokens << {
#           index: index,
#           surface: buffer,
#           furigana: buffer_furigana,
#           pos: "compound"
#         }
#       end

#       tokens
#     end
#   end
# end

require "natto"
require_relative "furigana_service"

module HandleData
  class TokenizerService
    # Trợ từ nên tách riêng nếu đứng cuối buffer
    PARTICLES_TO_SPLIT = %w[を に へ が は で と よ ね か も から まで ば ぞ さ ながら でも].freeze

    def self.tokenize(text)
      nm = Natto::MeCab.new
      tokens = []
      buffer = ""
      buffer_furigana = ""
      index = 0

      nm.parse(text) do |n|
        next if n.is_eos?

        surface = n.surface
        next if surface.blank? || %w[「 」].include?(surface)

        features = n.feature.split(",")
        pos = features[0]
        reading = features[7]
        furigana = if reading && reading != "*" && !reading.empty?
                     HandleData::FuriganaService.katakana_to_hiragana(reading)
                   else
                     surface
                   end

        # Gộp "な", "の" vào buffer
        if %w[な の].include?(surface) && buffer.present?
          buffer += surface
          buffer_furigana += furigana

        # Dấu câu → gộp vào từ trước
        elsif pos == "記号" && %w[、 。].include?(surface) && buffer.present?
          buffer += surface
          buffer_furigana += furigana

        # Phần của cụm động từ hoặc chữ Hiragana nhỏ → gộp
        elsif pos == "助詞" || pos == "助動詞" || surface.match?(/^[ぁぃぅぇぉゃゅょっー々]+$/)
          buffer += surface
          buffer_furigana += furigana

        else
          # Nếu có buffer → xử lý postprocessing
          if buffer.present?
            flush_buffer(tokens, buffer, buffer_furigana, index)
            index = tokens.length
          end

          buffer = surface
          buffer_furigana = furigana
        end
      end

      # Flush lần cuối
      if buffer.present?
        flush_buffer(tokens, buffer, buffer_furigana, index)
      end

      # Set lại index chuẩn
      tokens.each_with_index { |t, i| t[:index] = i }
      tokens
    end

    def self.flush_buffer(tokens, buffer, furigana, start_index)
      # Nếu buffer kết thúc bằng trợ từ trong danh sách thì tách ra
      PARTICLES_TO_SPLIT.each do |particle|
        if buffer.end_with?(particle) && buffer != particle
          part_pos = buffer.rindex(particle)
          main = buffer[0...part_pos]
          main_furi = furigana[0...part_pos]
          part = buffer[part_pos..]
          part_furi = furigana[part_pos..]

          tokens << {
            index: start_index,
            surface: main,
            furigana: main_furi,
            pos: "compound"
          }
          tokens << {
            index: start_index + 1,
            surface: part,
            furigana: part_furi,
            pos: "助詞"
          }
          return
        end
      end

      # Nếu không cần tách, thêm nguyên buffer
      tokens << {
        index: start_index,
        surface: buffer,
        furigana: furigana,
        pos: "compound"
      }
    end
  end
end
