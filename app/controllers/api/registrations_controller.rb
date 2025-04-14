class Api::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  # Các field cho phép khi đăng ký
  def sign_up_params
    params.require(:user).permit(
      :username,
      :email,
      :password,
      :password_confirmation,
      :dob,
      :phone
    )
  end

  # Các field cho phép khi cập nhật thông tin user (nếu dùng)
  def account_update_params
    params.require(:user).permit(
      :username,
      :email,
      :password,
      :password_confirmation,
      :current_password,
      :dob,
      :phone
    )
  end

  # Custom JSON trả về sau khi đăng ký thành công
  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        message: "Đăng ký thành công!",
        user: resource
      }, status: :created
    else
      render json: {
        error: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end
