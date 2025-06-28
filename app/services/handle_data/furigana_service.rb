require "natto"

module HandleData
  class FuriganaService
    def self.katakana_to_hiragana(katakana)
      katakana.tr("ァ-ン", "ぁ-ん")
    end

    def self.generate_furigana(text)
      nm = Natto::MeCab.new
      furigana = []

      nm.parse(text) do |n|
        features = n.feature.split(",")
        reading = features[7]

        if reading && reading != "*" && !reading.empty?
          hiragana = katakana_to_hiragana(reading)
          furigana << hiragana
        else
          furigana << n.surface
        end
      end

      furigana.join("")
    end
  end
end
