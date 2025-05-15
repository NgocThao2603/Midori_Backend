class Question < ApplicationRecord
  has_many :choices

  belongs_to :lesson
  belongs_to :vocabulary, optional: true
  belongs_to :phrase, optional: true
  belongs_to :example, optional: true

  has_many :example_tokens, through: :example
end
