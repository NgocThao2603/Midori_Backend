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

    def update
      exercise_type = params.dig(:user_exercise_status, :exercise_type)
      lesson_id = params[:id]

      unless exercise_type && lesson_id
        render json: { error: "Missing exercise_type or lesson_id" }, status: :unprocessable_entity
        return
      end

      status = UserExerciseStatus.find_or_initialize_by(
        user_id: current_user.id,
        lesson_id: lesson_id,
        exercise_type: exercise_type
      )

      status.done = true
      status.done_at ||= Time.current

      if status.save
        render json: { message: "Status updated successfully" }, status: :ok
      else
        render json: { error: status.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
