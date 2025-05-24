module Api
  class TestAnswersController < ApplicationController
    before_action :authenticate_user!
    before_action :set_test_attempt

    def index
      answers = @test_attempt.test_answers.includes(:question)
      render json: answers.as_json(only: [ :id, :question_id, :answer_text, :is_correct ])
    end

    def update_or_create
      raw_params = params.require(:test_answer).to_unsafe_h
      answer_value = raw_params[:answer]

      answer_text = answer_value.is_a?(Array) ? answer_value.to_json : answer_value.to_s

      test_answer = @test_attempt.test_answers.find_or_initialize_by(
        question_id: raw_params[:question_id]
      )

      test_answer.assign_attributes(
        answer_text: answer_text,
        is_correct: raw_params[:is_correct]
      )

      if test_answer.save
        render json: {
          id: test_answer.id,
          question_id: test_answer.question_id,
          answer: answer_value,
          is_correct: test_answer.is_correct
        }, status: :ok
      else
        render json: { errors: test_answer.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_test_attempt
      @test_attempt = TestAttempt.find(params[:test_attempt_id])
    end
  end
end
