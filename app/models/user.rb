class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  has_many :user_exercise_statuses, dependent: :destroy
  has_many :test_attempts, dependent: :destroy
  has_many :user_daily_activities, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  after_initialize :set_default_avatar, if: :new_record?

  def set_default_avatar
    self.avatar_url ||= "/avatars/avatar.svg"
  end
end
