class Api::QuestionsController < ApplicationController
  def index
    # Lấy câu hỏi theo lesson_id
    if params[:lesson_id].present?
      questions = Question.where(lesson_id: params[:lesson_id])
                         .includes(:choices, example: :example_tokens)

      questions = case params[:practice_type]
                when "phrase"
                  select_practice_phrase_questions(questions)
                when "example"
                  select_practice_example_questions(questions)
                else
                  questions
                end

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

  private

  def select_practice_phrase_questions(questions)
    max_questions = 30

    # Nhóm câu hỏi choice theo vocab/phrase/example
    choice_groups = questions.where(question_type: "choice")
                          .group_by { |q| [ q.vocabulary_id, q.phrase_id, q.example_id ].compact }

    # Random 1 câu từ mỗi nhóm choice
    random_choices = choice_groups.map { |_, group| group.sample }

    # Lấy các câu matching
    matching_questions = questions.where(question_type: "matching")
                                .to_a
                                .uniq { |q| [ q.vocabulary_id, q.phrase_id ].compact }

    # Random và giới hạn số lượng cho mỗi loại
    choice_total = max_questions * 2/3
    matching_total = max_questions - choice_total
    selected_choices = random_choices.sample([ random_choices.size, choice_total ].min)
    selected_matching = matching_questions.sample([ matching_questions.size, matching_total ].min)

    # Gộp và trộn kết quả
    (selected_choices + selected_matching).shuffle
  end

  def select_practice_example_questions(questions)
    max_questions = 20
    sort_total = 12
    fill_blank_total = 8

    used_example_ids = Set.new

    # Lấy sorting questions trước
    sorting_questions = questions
      .where(question_type: "sorting")
      .group_by { |q| q.example_id }
      .transform_values { |group| group.sample }
      .values

    selected_sorting = sorting_questions.sample([sorting_questions.size, sort_total].min)
    used_example_ids.merge(selected_sorting.map(&:example_id))

    # Lấy fill_blank questions, loại trừ các example_id đã dùng
    fill_blank_questions = questions
      .where(question_type: "fill_blank")
      .reject { |q| used_example_ids.include?(q.example_id) }
      .group_by { |q| q.example_id }
      .transform_values { |group| group.sample }
      .values

    selected_fill_blank = fill_blank_questions.sample([fill_blank_questions.size, fill_blank_total].min)

    (selected_sorting + selected_fill_blank).shuffle
  end
end
