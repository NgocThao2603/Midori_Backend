class ExampleToken < ApplicationRecord
  belongs_to :example

  validates :token_index, presence: true
  validates :jp_token, presence: true
end
