class Lesson < ApplicationRecord
  belongs_to :chapter
  has_many :vocabularies, dependent: :destroy
end
