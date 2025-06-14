module AutoGenQuestion
  class SortQuestionGeneratorService
    def initialize(lesson)
      @lesson = lesson
    end

    def call
      generate_sort_questions_from_examples
    end

    private

    def generate_sort_questions_from_examples
      Example.includes(:vocabulary).where(vocabulary: @lesson.vocabularies).find_each do |example|
        next if example.example_sentence.blank? || example.meaning_sentence.blank?

        Question.create!(
          lesson: @lesson,
          example: example,
          question_type: "sorting",
          question: example.meaning_sentence,
          correct_answers: [ example.example_sentence ]
        )
      end
    end
  end
end
