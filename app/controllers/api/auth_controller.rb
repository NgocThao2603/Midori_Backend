module Api
  class AuthController < ApplicationController
    # API kiểm tra trùng email và username
    def check_existing
      if params[:username].present?
        user = User.find_by(username: params[:username])
        if user
          render json: { error: "Username đã tồn tại" }, status: :unprocessable_entity
          return
        end
      end
      
      if params[:email].present?
        user = User.find_by(email: params[:email])
        if user
          render json: { error: "Email đã tồn tại" }, status: :unprocessable_entity
          return
        end
      end
      render json: { message: "Thông tin hợp lệ" }, status: :ok
    end

    private
  end
end
