class Chapter < ApplicationRecord
  has_many :lessons, dependent: :destroy
end
