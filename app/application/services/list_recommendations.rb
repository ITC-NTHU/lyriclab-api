# frozen_string_literal: true

require 'dry/monads'

module LyricLab
  module Service
    # Retrieves array of all listed project entities
    class ListRecommendations
      include Dry::Monads::Result::Mixin

      def call()
        recommendations = Repository::For.klass(Entity::Recommendation).top_searched_songs
        Success(recommendations)
      rescue StandardError
        Failure('could not access database')
      end
    end
  end
end