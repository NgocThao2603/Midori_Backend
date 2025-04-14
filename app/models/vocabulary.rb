class Vocabulary < ApplicationRecord
  belongs_to :lesson
  has_many :meanings, dependent: :destroy
  has_many :examples, dependent: :destroy
  has_many :phrases, dependent: :destroy
end
