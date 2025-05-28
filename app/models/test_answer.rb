class TestAnswer < ApplicationRecord
  belongs_to :test_attempt
  belongs_to :question
end
