# frozen_string_literal: true

require 'dry/monads'

module LyricLab
  module Service
    # Retrieves array of all listed project entities
    class Record
      include Dry::Monads::Result::Mixin

      def call(song)
        recommendation = Entity::Recommendation.new(song.title, song.artist_name_string, 1, song.spotify_id)
        Repository::For.entity(recommendation).create(recommendation)
        Success(song)
      rescue StandardError
        Failure('could not access database')
      end
    end
  end
end
