module Api
  class AuthController < ApplicationController
    require "jwt"

    SECRET_KEY = Rails.application.credentials.secret_key_base || ENV["SECRET_KEY_BASE"]

    # Đăng ký
    def register
      user = User.new(user_params)
      if user.save
        render json: { message: "User created successfully" }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Đăng nhập
    def login
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        token = encode_token({ user_id: user.id })
        render json: { token: token, user: user }, status: :ok
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    private

    def user_params
      params.permit(:username, :email, :password, :password_confirmation, :dob, :phone)
    end

    def encode_token(payload)
      JWT.encode(payload, SECRET_KEY, "HS256")
    end
  end
end
