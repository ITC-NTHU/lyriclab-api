# frozen_string_literal: true

require 'dry/monads'
require 'dry/transaction'

module LyricLab
  module Service
    # Retrieves array of the top recommendations
    class ListTargetedRecommendations
      include Dry::Transaction

      step :extract_recommendations

      private

      DB_ERR = 'could not access database'

      def extract_recommendations(input_language_difficulty)
        Repository::For.klass(Entity::Recommendation).top_songs_for_difficulty(input_language_difficulty)
          .then { |recommendations| Response::RecommendationsList.new(recommendations) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      rescue StandardError => e
        App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
