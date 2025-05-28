class AutoSubmitTestAttemptJob < ApplicationJob
  queue_as :default

  def perform(test_attempt_id)
    test_attempt = TestAttempt.find_by(id: test_attempt_id)
    return unless test_attempt && test_attempt.status == "in_progress"
    return unless Time.current >= test_attempt.start_time + test_attempt.test.duration_minutes.minutes

    TestAttemptSubmitter.new(test_attempt).submit!(auto: true)
  end
end
