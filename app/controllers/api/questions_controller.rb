class Api::QuestionsController < ApplicationController
  def index
    # Lấy câu hỏi theo lesson_id
    if params[:lesson_id].present?
      questions = Question.where(lesson_id: params[:lesson_id])
                         .includes(:choices, example: :example_tokens)

      questions = questions.map do |question|
        if question.question_type == "fill_blank"
          question.as_json(except: [ :choices, :example_tokens ])
        else
          question
        end
      end

      render json: questions, include: [ "choices", "example_tokens" ], status: :ok
    else
      render json: { error: "lesson_id is required" }, status: :unprocessable_entity
    end
  end
end
