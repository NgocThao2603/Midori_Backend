module Api
  class SessionsController < Devise::SessionsController
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      render json: {
        message: "Đăng nhập thành công!",
        user: resource,
        token: request.env['warden-jwt_auth.token']
      }, status: :ok
    end

    def respond_to_on_destroy
      if current_user
        render json: { message: "Đăng xuất thành công!" }, status: :ok
      else
        render json: { message: "Token không hợp lệ hoặc đã hết hạn!" }, status: :unauthorized
      end
    end
  end
end
