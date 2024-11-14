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
        Success(song)
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        Failure(e.to_s)
      end
    end
  end
end
