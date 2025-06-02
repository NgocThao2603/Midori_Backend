module Api
  class UsersController < ApplicationController
    before_action :authenticate_user!

    def profile
      render json: { user: current_user }
    end

    def overall_ranking
      begin
        raise "User not authenticated" unless current_user
        users = User.select(:id, :username, :point)
                   .order(point: :desc)
                   .map { |user| user.as_json.slice("id", "username", "point") }

        render json: {
          rankings: users,
          current_user_id: current_user.id
        }
      rescue => e
        Rails.logger.error "Overall ranking error: #{e.message}"
        render json: { error: "Internal server error" }, status: :internal_server_error
      end
    end

    # Lấy ranking theo level và thời gian
    def level_ranking
      level = params[:level]
      time_range = case params[:period]
      when "day"
        Time.current.beginning_of_day..Time.current.end_of_day
      when "week"
        Time.current.beginning_of_week..Time.current.end_of_week
      when "month"
        Time.current.beginning_of_month..Time.current.end_of_month
      else
        Time.current.beginning_of_day..Time.current.end_of_day
      end

      rankings = UserDailyActivity
        .where(level: level, activity_date: time_range)
        .group(:user_id)
        .sum(:point_earned)
        .sort_by { |_, points| -points }
        .map do |user_id, total_points|
          user = User.select(:id, :username).find(user_id)
          {
            id: user.id,
            username: user.username,
            point: total_points
          }
        end

      render json: {
        rankings: rankings,
        current_user_id: current_user.id
      }
    end
  end
end
