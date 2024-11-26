# frozen_string_literal: true

require 'dry/monads'
require 'dry/transaction'

module LyricLab
  module Service
    # Retrieves array of all listed project entities
    class ListRecommendations
      include Dry::Transaction

      step :extract_recommendations

      private

      DB_ERR = 'could not access database'

      def extract_recommendations
        Repository::For.klass(Entity::Recommendation).top_searched_songs
          .then { |recommendations| Response::RecommendationsList.new(recommendations) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
