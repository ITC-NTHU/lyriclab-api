# frozen_string_literal: true

require 'dry/monads'

module LyricLab
  module Service
    # Retrieves array of all listed project entities
    class Record
      include Dry::Monads::Result::Mixin

      def call(origin_id)
        song = Repository::For.klass(Entity::Song).find_spotify_id(origin_id)
        recommendation = Entity::Recommendation.new(song.title, song.artist_name_string, 1, song.spotify_id)
        Repository::For.entity(recommendation).create(recommendation)
        Success(Response::ApiResult.new(status: :ok, message: recommendation))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: 'having trouble updating recommendations'))
      end
    end
  end
end
