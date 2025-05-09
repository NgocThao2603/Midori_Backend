class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :lesson_id, :vocabulary_id, :phrase_id, :example_id,
             :question, :question_type, :correct_answers, :hidden_part,
             :created_at, :updated_at

  has_many :choices, if: -> { object.question_type.in?(%w[choice matching]) }

  # Có thể thêm logic tương tự này sau nếu thêm sorting hoặc fill_blank
  # attribute :tokens, if: -> { object.question_type == 'sorting' }
  # attribute :blanks, if: -> { object.question_type == 'fill_blank' }
end
