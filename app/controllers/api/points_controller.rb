module Api
  class PointsController < ApplicationController
    before_action :authenticate_user!

    def show
      render json: { point: current_user.point }
    end

    def update
      point = params.dig(:user_point, :point)&.to_i
      update_type = params.dig(:user_point, :update_type)

      unless point && update_type
        render json: { error: "Missing point or update_type" }, status: :unprocessable_entity
        return
      end

      begin
        case update_type
        when "add"
          current_user.point += point
        when "set" 
          current_user.point = point
        else
          render json: { error: "Invalid update_type" }, status: :unprocessable_entity
          return
        end

        if current_user.save
          render json: { point: current_user.point }
        else
          render json: { error: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    private

    def point_params
      params.require(:user_point).permit(:point, :update_type)
    end
  end
end
