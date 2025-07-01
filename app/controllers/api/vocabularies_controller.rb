module Api
  class VocabulariesController < ApplicationController
    def by_lesson
      lesson = Lesson.find_by(id: params[:lesson_id])

      if lesson.nil?
        render json: { error: "Lesson not found" }, status: :not_found
        return
      end

      vocabularies = lesson.vocabularies.includes(:meanings, :phrases).map do |vocab|
        {
          id: vocab.id,
          stt: vocab.stt,
          kanji: vocab.kanji,
          hanviet: vocab.hanviet,
          kana: vocab.kana,
          word_type: vocab.word_type,
          meanings: vocab.meanings.map(&:meaning),
          phrases: vocab.phrases.map do |phrase|
            {
              id: phrase.id,
              vocab_stt: vocab.stt,
              phrase: phrase.phrase,
              main_word: phrase.main_word,
              prefix: phrase.prefix,
              suffix: phrase.suffix,
              meaning: phrase.meaning,
              phrase_type: phrase.phrase_type,
              furigana: phrase.furigana
            }
          end
        }
      end

      render json: vocabularies
    end
  end
end
