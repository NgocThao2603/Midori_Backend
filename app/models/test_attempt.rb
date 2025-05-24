class TestAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :test
  has_many :test_answers, dependent: :destroy
  has_many :test_questions, dependent: :destroy
  has_many :questions, through: :test_questions
end
