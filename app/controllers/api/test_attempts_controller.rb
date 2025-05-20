module Api
  class TestAttemptsController < ApplicationController
    def show
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
        questions: test_attempt.test_questions.map do |taq|
          {
            question_id: taq.question_id,
            question_type: taq.question.question_type
          }
        end
      }
    end

    def create
      test = Test.find(params[:test_id])
      lesson_id = test.lesson_id

      # Step 1: Tạo test_attempt
      test_attempt = TestAttempt.create!(
        user_id: current_user.id,
        test_id: test.id,
        start_time: Time.current
      )

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

      # Step 4: Cập nhật total_score, pass_score nếu không đủ số lượng yêu cầu
      if all_questions.size < 40
        total = selected[:choice_matching].size * 2 + selected[:sorting].size * 3 + selected[:fill_blank].size * 3
        test.update!(
          total_score: total,
          pass_score: (total * 0.75).round
        )
      end

      render json: {
        test_attempt: test_attempt,
        test_questions: all_questions.map { |q| { id: q.id, type: q.question_type } }
      }, status: :created
    end

    private

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
