# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Transaction to store project from Github API to database
    class LoadSong
      include Dry::Transaction

      step :load_song_from_database

      private

      def load_song_from_database(input)
        song = Repository::For.klass(Entity::Song).find_spotify_id(input)
        Success(Response::ApiResult.new(status: :ok, message: song))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: 'cannot load the song'))
      end
    end
  end
end
