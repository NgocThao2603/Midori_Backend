class Api::QuestionsController < ApplicationController
  def index
    # Lấy câu hỏi theo lesson_id
    if params[:lesson_id].present?
      questions = Question.where(lesson_id: params[:lesson_id])
      render json: questions, include: :choices, status: :ok
    else
      render json: { error: "lesson_id is required" }, status: :unprocessable_entity
    end
  end
end
