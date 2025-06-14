module AutoGenQuestion
  class MatchQuestionGeneratorService
    def initialize(lesson)
      @lesson = lesson
    end

    def call
      generate_match_questions_from_phrases
    end

    private

    def generate_match_questions_from_phrases
      phrases = Phrase.where(vocabulary_id: @lesson.vocabularies.pluck(:id))
                      .where.not(prefix: [nil, ""], suffix: [nil, ""])

      phrases.each do |phrase|
        hidden_phrase = phrase.phrase.dup
        correct_answers = []
        choices = []

        if phrase.prefix.present?
          hidden_phrase.sub!(phrase.prefix, "___")
          correct_answers << phrase.prefix
          choices << phrase.prefix
        end

        if phrase.suffix.present?
          hidden_phrase.sub!(phrase.suffix, "___")
          correct_answers << phrase.suffix
          choices << phrase.suffix
        end

        next if correct_answers.empty?

        # Lấy thêm các distractor (câu sai), loại trừ prefix/suffix đang dùng
        distractors = Phrase.where.not(id: phrase.id)
                            .pluck(:prefix, :suffix)
                            .flatten
                            .compact
                            .reject { |w| correct_answers.include?(w) }
                            .uniq
                            .sample(6 - correct_answers.size)

        # Trộn các đáp án đúng và sai
        all_choices = (choices + distractors).shuffle

        # Tạo câu hỏi
        Question.create!(
          lesson: @lesson,
          question_type: "matching",
          question: "#{hidden_phrase}",
          phrase: phrase,
          correct_answers: correct_answers
        ).tap do |question|
          all_choices.each do |choice|
            Choice.create!(
              question: question,
              choice: choice,
              is_correct: correct_answers.include?(choice)
            )
          end
        end
      end
    end
  end
end
