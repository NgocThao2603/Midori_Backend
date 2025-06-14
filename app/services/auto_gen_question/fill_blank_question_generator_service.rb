module AutoGenQuestion
  class FillBlankQuestionGeneratorService
    def initialize(lesson)
      @lesson = lesson
    end

    def call
      generate_fill_blank_questions_from_examples
    end

    private

    def generate_fill_blank_questions_from_examples
      Example.includes(:vocabulary).where(vocabulary: @lesson.vocabularies).find_each do |example|
        next if example.example_sentence.blank? || example.meaning_sentence.blank?

        Question.create!(
          lesson: @lesson,
          example: example,
          question_type: "fill_blank",
          question: example.meaning_sentence,
          correct_answers: [ example.example_sentence ]
        )
      end
    end
  end
end
