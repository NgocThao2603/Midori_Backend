require "net/http"
require "json"
require "uri"

module HandleData
  class TranslationService
    def self.translate_to_vietnamese(japanese_text)
      return japanese_text if japanese_text.blank?

      begin
        encoded_text = URI.encode_www_form_component(japanese_text)
        url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=ja&tl=vi&dt=t&q=#{encoded_text}"

        uri = URI(url)
        response = Net::HTTP.get_response(uri)

        if response.code == "200"
          result = JSON.parse(response.body)
          translated = result[0][0][0] if result&.dig(0, 0, 0)

          if translated.present? && translated != japanese_text
            return translated.strip
          end
        end
      rescue => e
        puts "Translation error for '#{japanese_text}': #{e.message}"
      end

      # Fallback về text gốc nếu dịch không thành công
      japanese_text
    end
  end
end
