class TestAttemptSubmitter
  def initialize(test_attempt)
    @test_attempt = test_attempt
  end

  def submit!(auto: false)
    return unless @test_attempt.status == "in_progress"

    answers = TestAnswer.where(test_attempt_id: @test_attempt.id)
    test_questions = TestQuestion.where(test_attempt_id: @test_attempt.id).index_by(&:question_id)

    answered_count = answers.count
    correct_count = answers.where(is_correct: true).count
    total_questions = test_questions.size
    ratio = total_questions.zero? ? 0 : (answered_count.to_f / total_questions)

    if auto && ratio <= 0.5
      status = "abandoned"
      total_score = 0
    else
      status = "completed"
      total_score = answers.sum do |answer|
        answer.is_correct ? (test_questions[answer.question_id]&.score || 0) : 0
      end
    end

    @test_attempt.update!(
      status: status,
      score: total_score,
      answered_count: answered_count,
      end_time: Time.current,
      auto_submitted: auto
    )

    if status == "completed" && total_score >= @test_attempt.test.pass_score
      add_point_to_user!
      mark_lesson_test_done!
    end

    correct_count
  end

  private

  def add_point_to_user!
    user = @test_attempt.user
    user.update!(point: user.point + @test_attempt.score.to_i)
  end

  def mark_lesson_test_done!
    status = UserExerciseStatus.find_or_create_by!(
      user_id: @test_attempt.user_id,
      lesson_id: @test_attempt.test.lesson_id,
      exercise_type: "test"
    )
    return if status.done?

    status.update!(
      done: true,
      done_at: status.done_at || Time.current
    )
  end
end
