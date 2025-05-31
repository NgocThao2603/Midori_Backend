module Api
  class UserDailyActivitiesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user_daily_activity, only: [ :mark_studied, :update_point ]

    def index
      activities = current_user.user_daily_activities
      activities = activities.where(level: params[:level]) if params[:level].present?

      render json: activities, status: :ok
    end

    def mark_studied
      if @user_daily_activity.persisted? && @user_daily_activity.is_studied?
        render json: { message: "Already marked as studied", activity: @user_daily_activity }, status: :ok
        return
      end

      if @user_daily_activity.update(is_studied: true)
        render json: { message: "Marked as studied", activity: @user_daily_activity }, status: :ok
      else
        render json: { errors: @user_daily_activity.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update_point
      point = params[:point_earned].to_i
      if point < 0
        return render json: { errors: [ "point_earned must be non-negative" ] }, status: :unprocessable_entity
      end

      new_earned_point = @user_daily_activity.point_earned.to_i + point

      if @user_daily_activity.update(point_earned: new_earned_point)
        render json: { message: "Point updated", activity: @user_daily_activity }, status: :ok
      else
        render json: { errors: @user_daily_activity.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_user_daily_activity
      level = params[:level]
      if level.blank?
        render json: { errors: [ "level is required" ] }, status: :bad_request and return
      end
      begin
        @user_daily_activity = UserDailyActivity.find_or_create_by!(
          user_id: current_user.id,
          activity_date: params[:activity_date] || Date.today,
          level: level
        )
      rescue ActiveRecord::RecordNotUnique
        # Nếu có request song song gây race condition → retry
        retry
      rescue => e
        logger.error "Failed to find or create user_daily_activity: #{e.message}"
        render json: { errors: [ "Internal server error" ] }, status: :internal_server_error
      end
    end
  end
end
