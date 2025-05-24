class Test < ApplicationRecord
  belongs_to :lesson
  has_many :test_attempts, dependent: :destroy
  has_many :test_questions, through: :test_attempts
  has_many :questions, through: :test_questions
end
