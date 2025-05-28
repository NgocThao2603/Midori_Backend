module Api
  class TestAttemptsController < ApplicationController
    before_action :set_test_attempt, only: [ :show, :submit ]
    before_action :authenticate_user!

    def index
      if params[:test_id].present?
        test_attempts = TestAttempt.where(test_id: params[:test_id])
                                  .where(user_id: current_user.id)
                                  .order(created_at: :desc)

        render json: test_attempts.as_json(only: [
          :id, :test_id, :user_id, :status, :score,
          :start_time, :end_time, :answered_count, :created_at
        ])
      else
        render json: { error: "Missing test_id" }, status: :bad_request
      end
    end

    def show
      if @test_attempt.user_id != current_user.id
        render json: { error: "Unauthorized" }, status: :unauthorized and return
      end

      test_attempt = TestAttempt.includes(test_questions: :question).find(params[:id])

      render json: {
        id: test_attempt.id,
        test_id: test_attempt.test_id,
        user_id: test_attempt.user_id,
        status: test_attempt.status,
        score: test_attempt.score,
        start_time: test_attempt.start_time,
        end_time: test_attempt.end_time,
        answered_count: test_attempt.answered_count,
        test: {
          pass_score: test_attempt.test.pass_score,
          id: test_attempt.test_id,
          lesson_id: test_attempt.test.lesson_id,
          duration_minutes: test_attempt.test.duration_minutes
        },
        questions: test_attempt.test_questions.map do |taq|
          {
            question_id: taq.question_id,
            question_type: taq.question.question_type
          }
        end
      }
    end

    def create
      test = Test.find_by(id: params[:test_id])
      unless test
        render json: { error: "Test not found" }, status: :not_found and return
      end
      lesson_id = test.lesson_id

      # Step 1: Tạo test_attempt
      test_attempt = TestAttempt.create!(
        user_id: current_user.id,
        test_id: test.id,
        start_time: Time.current
      )

      AutoSubmitTestAttemptJob.set(
        wait_until: test_attempt.start_time + test.duration_minutes.minutes
      ).perform_later(test_attempt.id)

      # Step 2: Lấy và chọn câu hỏi
      questions = Question.where(lesson_id: lesson_id)

      choice_matching = questions.where(question_type: %w[choice matching])
      sorting = questions.where(question_type: "sorting")
      fill_blank = questions.where(question_type: "fill_blank")

      selected = {
        choice_matching: select_unique(choice_matching, %w[vocabulary_id phrase_id], 20),
        sorting: select_unique(sorting, %w[example_id], 10),
        fill_blank: select_unique(fill_blank, %w[example_id], 10)
      }

      # Nếu thiếu, nới lỏng điều kiện và lấy thêm
      selected[:choice_matching] = complete_set(choice_matching, selected[:choice_matching], 20)
      selected[:sorting] = complete_set(sorting, selected[:sorting], 10)
      selected[:fill_blank] = complete_set(fill_blank, selected[:fill_blank], 10)

      all_questions = selected.values.flatten

      # Step 3: Tạo test_questions
      all_questions.each do |q|
        score = case q.question_type
                when "choice", "matching" then 2
                when "sorting", "fill_blank" then 3
                else 1
                end

        TestQuestion.create!(
          test_attempt_id: test_attempt.id,
          question_id: q.id,
          score: score
        )
      end

      # Step 4: Cập nhật total_score, pass_score
      total = selected[:choice_matching].size * 2 + selected[:sorting].size * 3 + selected[:fill_blank].size * 3
      test.update!(
        total_score: total,
        pass_score: (total * 0.75).round
      )

      render json: { id: test_attempt.id }, status: :created
    end

    def submit
      if @test_attempt.user_id != current_user.id
        render json: { error: "Unauthorized" }, status: :unauthorized and return
      end

      if @test_attempt.status != "in_progress"
        render json: { error: "Bài đã được nộp hoặc bị bỏ dở" }, status: :unprocessable_entity
        return
      end

      correct_count = TestAttemptSubmitter.new(@test_attempt).submit!(auto: false)

      render json: {
        message: "Đã nộp bài thành công",
        status: @test_attempt.status,
        score: @test_attempt.score,
        answer_count: @test_attempt.answered_count,
        correct_count: correct_count,
        end_time: @test_attempt.end_time
      }, status: :ok
    end

    private

    def set_test_attempt
      @test_attempt = TestAttempt.find_by(id: params[:id])
      unless @test_attempt
        render json: { error: "TestAttempt not found" }, status: :not_found
      end
    end

    # Lấy danh sách câu hỏi không trùng key (ví dụ: vocabulary_id, phrase_id)
    def select_unique(scope, unique_keys, limit)
      selected = []
      used = {}

      scope.shuffle.each do |q|
        keys = unique_keys.map { |k| q.send(k) }
        next if keys.any? { |k| k && used[k] }

        selected << q
        keys.each { |k| used[k] = true if k }
        break if selected.size >= limit
      end

      selected
    end

    # Nếu thiếu câu hỏi sau lọc, lấy thêm từ cùng loại (có thể trùng key)
    def complete_set(scope, current, target)
      return current if current.size >= target

      remaining = scope.where.not(id: current.map(&:id)).limit(target - current.size)
      current + remaining
    end
  end
end
