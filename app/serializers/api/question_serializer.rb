class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :lesson_id, :vocabulary_id, :phrase_id, :example_id,
             :question, :question_type, :correct_answers, :hidden_part,  :tokens,
             :created_at, :updated_at

  has_many :choices, if: -> { object.question_type.in?(%w[choice matching]) }

  # has_many :example_tokens, serializer: ExampleTokenSerializer, if: -> { object.question_type == "sorting" && object.example.present? }
  has_many :example_tokens,
            serializer: ExampleTokenSerializer,
            if: -> { object.question_type == "sorting" } do
          # Call sorted_tokens với hidden_part của question hiện tại
          object.example&.sorted_tokens(object.hidden_part)
          end
  attribute :choices, if: -> { object.question_type != "fill_blank" }
  attribute :example_tokens, if: -> { object.question_type != "fill_blank" }
end
