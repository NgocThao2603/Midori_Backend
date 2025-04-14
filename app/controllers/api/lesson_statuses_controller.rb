module Api
  class LessonStatusesController < ApplicationController
    before_action :authenticate_user!

    def index
      lesson_ids = Lesson.pluck(:id)

      lesson_statuses = UserExerciseStatus
                          .where(user_id: current_user.id, lesson_id: lesson_ids)
                          .done

      # Map mặc định cho mỗi lesson
      status_map = lesson_ids.index_with do |_|
        {
          phrase: false,
          translate: false,
          listen: false,
          test: false
        }
      end

      # Merge dữ liệu đã hoàn thành vào map
      lesson_statuses.each do |status|
        status_map[status.lesson_id][status.exercise_type.to_sym] = true
      end

      render json: status_map
    end
  end
end
