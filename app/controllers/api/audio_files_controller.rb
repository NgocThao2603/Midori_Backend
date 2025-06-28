class Api::AudioFilesController < ApplicationController
  def index
    render json: AudioFile.all
  end
end
