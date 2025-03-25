module Api
  class ChaptersController < ApplicationController
    def index
      level = params[:level]
      chapters = level.present? ? Chapter.where(level: level) : Chapter.all
      render json: chapters, include: :lessons
    end
  end
end
