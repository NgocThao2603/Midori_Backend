class UserExerciseStatus < ApplicationRecord
  belongs_to :user
  belongs_to :lesson

  enum :exercise_type, {
    phrase: "phrase",
    translate: "translate",
    listen: "listen",
    test: "test"
  }
  scope :done, -> { where(done: true) }
end
