class UserDailyActivity < ApplicationRecord
  belongs_to :user

  validates :level, presence: true
  validates :activity_date, presence: true, uniqueness: { scope: [ :user_id, :level ] }
  validates :point_earned, numericality: { greater_than_or_equal_to: 0 }
end
