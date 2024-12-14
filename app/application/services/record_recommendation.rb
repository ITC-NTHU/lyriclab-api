# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Updates the recommendation record in the db
    class RecordRecommendation
      include Dry::Transaction

      step :load_song_from_db
      step :save_recommendation_to_db

      private

      def load_song_from_db(origin_id)
        song = Service::LoadSong.new.call(origin_id)
        if song.success?

          Success(song.value!.message)
        else
          Failure(Response::ApiResult.new(status: :internal_error, message: 'cannot load song from db'))
        end
      end

      def save_recommendation_to_db(song) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        raise 'song has no language_difficulty' if song.vocabulary.empty?

        puts "language_difficulty to persist: #{song.vocabulary.language_difficulty}"
        record = {
          title: song.title,
          artist_name_string: song.artist_name_string,
          search_cnt: 1,
          origin_id: song.origin_id,
          language_difficulty: song.vocabulary.language_difficulty,
          cover_image_url_small: song.cover_image_url_small
        }
        recommendation = Entity::Recommendation.new(record)
        puts "Language_difficulty in entity: #{recommendation.language_difficulty}"
        Repository::For.entity(recommendation).create_or_increment_count(recommendation)
        Success(Response::ApiResult.new(status: :ok, message: recommendation))
      rescue StandardError => e
        if e.message == 'song has no language_difficulty'
          return Failure(Response::ApiResult.new(status: :internal_error, message: 'song has no language_difficulty'))
        end

        App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'having trouble updating recommendations'))
      end
    end
  end
end
