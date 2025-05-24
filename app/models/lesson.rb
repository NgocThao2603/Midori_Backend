class Lesson < ApplicationRecord
  belongs_to :chapter
  has_many :vocabularies, dependent: :destroy
  has_many :tests
  has_many :questions
end
