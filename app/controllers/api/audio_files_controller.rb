class Api::AudioFilesController < ApplicationController
  def index
    audio_files = AudioFile.all

    data = audio_files.map do |audio|
      id =
        case audio.audio_type
        when "vocab"
          audio.vocabulary_id
        when "phrase"
          audio.phrase_id
        when "example"
          audio.example_id
        when "example_token"
          audio.example_token_id
        end

      audio.as_json.merge(
        audio_url: "#{request.base_url}/audio/#{audio.audio_type}#{id}.mp3"
      )
    end

    render json: data
  end
end
