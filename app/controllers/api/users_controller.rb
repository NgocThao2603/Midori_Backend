module Api
  class UsersController < ApplicationController
    before_action :authorize_request, only: [ :profile ]

    def profile
      render json: { user: @current_user }
    end
  end
end
