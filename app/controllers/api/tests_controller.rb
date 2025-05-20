module Api
  class TestsController < ApplicationController
    def by_lesson
      lesson = Lesson.find_by(id: params[:lesson_id])
      if lesson
        render json: lesson.tests
      else
        render json: { error: "Lesson not found" }, status: :not_found
      end
    end
  end
end
