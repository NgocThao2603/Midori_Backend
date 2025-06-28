module Api
  class QuestionSerializer < ActiveModel::Serializer
    attributes :id, :lesson_id, :vocabulary_id, :phrase_id, :example_id,
              :question, :question_type, :correct_answers, :hidden_part,
              :created_at, :updated_at

    has_many :choices, if: -> { object.question_type.in?(%w[choice matching]) }

    has_many :example_tokens,
            serializer: ExampleTokenSerializer,
            if: -> { object.question_type == "sorting" && object.example.present? }

    # Nếu là fill_blank thì không include choices và example_tokens (handled by above)
  end
end
