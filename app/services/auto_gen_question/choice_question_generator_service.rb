module AutoGenQuestion
  class ChoiceQuestionGeneratorService
    def initialize(lesson)
      @lesson = lesson
    end

    def call
      generate_questions_for_vocabularies
      generate_questions_for_phrases
      generate_questions_from_examples
    end

    private

    def generate_questions_for_vocabularies
      @lesson.vocabularies.includes(:meanings).each do |vocab|
        # Hỏi kana (furigana)
        create_choice_question(
          lesson: @lesson,
          vocabulary: vocab,
          question_text: "Cách đọc đúng của「#{vocab.kanji}」là gì?",
          correct_choice: vocab.kana,
          wrong_choices: Vocabulary.where.not(id: vocab.id).pluck(:kana).sample(3)
        )

        # Hỏi meaning
        next if vocab.meanings.empty?
        create_choice_question(
          lesson: @lesson,
          vocabulary: vocab,
          question_text: "Nghĩa đúng của 「#{vocab.kanji}」là gì?",
          correct_choice: vocab.meanings.first.meaning,
          wrong_choices: Meaning.where.not(vocabulary_id: vocab.id).pluck(:meaning).sample(3)
        )
      end
    end

    def generate_questions_for_phrases
      Phrase.where(vocabulary_id: @lesson.vocabularies.pluck(:id)).each do |phrase|
        # Hỏi furigana
        create_choice_question(
          lesson: @lesson,
          phrase: phrase,
          question_text: "Cách đọc đúng của 「#{phrase.phrase}」là gì?",
          correct_choice: phrase.furigana,
          wrong_choices: Phrase.where.not(id: phrase.id).pluck(:furigana).compact.sample(3)
        )

        # Hỏi meaning
        create_choice_question(
          lesson: @lesson,
          phrase: phrase,
          question_text: "Nghĩa đúng của 「#{phrase.phrase}」là gì?",
          correct_choice: phrase.meaning,
          wrong_choices: Phrase.where.not(id: phrase.id).pluck(:meaning).sample(3)
        )
      end
    end

    def generate_questions_from_examples
      Example.includes(:vocabulary).where(vocabulary: @lesson.vocabularies).each do |example|
        vocab = example.vocabulary
        next unless example.example_sentence.include?(vocab.kanji)

        hidden_sentence = example.example_sentence.gsub(vocab.kanji, "____")
        create_choice_question(
          lesson: @lesson,
          example: example,
          question_text: "#{hidden_sentence}",
          correct_choice: vocab.kanji,
          wrong_choices: Vocabulary.where.not(id: vocab.id).pluck(:kanji).sample(3),
          hidden_part: vocab.kanji
        )
      end
    end

    def create_choice_question(lesson:, question_text:, correct_choice:, wrong_choices:, vocabulary: nil, phrase: nil, example: nil, hidden_part: nil)
      question = Question.create!(
        lesson: lesson,
        question_type: "choice",
        question: question_text,
        vocabulary: vocabulary,
        phrase: phrase,
        example: example,
        correct_answers: [correct_choice],
        hidden_part: hidden_part
      )

      # Shuffle cả đúng và sai
      all_choices = ([ { choice: correct_choice, is_correct: true } ] +
                    wrong_choices.map { |w| { choice: w, is_correct: false } }).shuffle

      all_choices.each do |c|
        Choice.create!(question: question, choice: c[:choice], is_correct: c[:is_correct])
      end
    end
  end
end
