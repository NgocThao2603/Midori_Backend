class Phrase < ApplicationRecord
  belongs_to :vocabulary
  has_many :questions, dependent: :destroy
end
