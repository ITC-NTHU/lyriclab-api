# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Load vocabulary from db
    class LoadVocabulary
      include Dry::Transaction

      step :find_song_db

      private

      def find_song_db(input_id)
        song = Repository::For.klass(Entity::Song).find_origin_id(input_id)
        Failure(Response::ApiResult.new(status: :not_found, message: 'vocabulary not found')) if song.vocabulary.empty?
        Success(song)
      rescue StandardError => e
        App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'cannot access db'))
      end
    end
  end
end
