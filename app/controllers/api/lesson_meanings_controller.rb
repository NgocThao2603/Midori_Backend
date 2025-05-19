module Api
  class LessonMeaningsController < ApplicationController
    def index
      lesson = Lesson.find_by(id: params[:lesson_id])

      if lesson.nil?
        render json: { error: "Lesson not found" }, status: :not_found
        return
      end

      vocabularies = lesson.vocabularies.includes(:meanings).map do |vocab|
        {
          id: vocab.id,
          kana: vocab.kana,
          meanings: vocab.meanings.map(&:meaning)
        }
      end

      phrases = lesson.vocabularies.flat_map(&:phrases).map do |phrase|
        {
          id: phrase.id,
          meaning: phrase.meaning
        }
      end

      examples = lesson.vocabularies.flat_map(&:examples).map do |example|
        {
          id: example.id,
          meaning: example.meaning_sentence
        }
      end

      render json: {
        vocabularies: vocabularies,
        phrases: phrases,
        examples: examples
      }
    end
  end
end
