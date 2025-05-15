class AudioFile < ApplicationRecord
  belongs_to :vocabulary, optional: true
  belongs_to :phrase, optional: true
  belongs_to :example, optional: true
  belongs_to :example_token, optional: true

  enum :audio_type, { vocab: "vocab", phrase: "phrase", example: "example", example_token: "example_token" }
end
