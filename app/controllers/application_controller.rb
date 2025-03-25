class ApplicationController < ActionController::API
  SECRET_KEY = ENV["SECRET_KEY_BASE"] || Rails.application.credentials.secret_key_base

  def authorize_request
    header = request.headers["Authorization"]
    if header.present?
      token = header.split(" ").last
      begin
        decoded = JWT.decode(token, SECRET_KEY, true, algorithm: "HS256")
        @current_user = User.find(decoded[0]["user_id"])
      rescue JWT::ExpiredSignature
        render json: { error: "Token has expired" }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: "Invalid token" }, status: :unauthorized
      end
    else
      render json: { error: "Missing token" }, status: :unauthorized
    end
  end
end
