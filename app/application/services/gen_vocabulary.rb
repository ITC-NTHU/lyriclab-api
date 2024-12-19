# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Generate Vocabulary Data using ChatGPT
    class GenVocabulary
      include Dry::Transaction

      # step :find_song_details
      # step :check_song_eligibility
      # step :request_vocabulary_factory_worker
      step :united

      private

      DB_ERR = 'Having trouble accessing the database'
      NO_SONG_ERR = 'Song not found'
      PROCESSING_MSG = 'vocabulary generation in progress'

      def united(input)
        song = Repository::For.klass(Entity::Song).find_origin_id(input[:origin_id])
        return Success(Response::ApiResult.new(status: :created, message: song)) unless song.vocabulary.empty?

        Messaging::Queue.new(App.config.VOCABULARY_QUEUE_URL, App.config)
          .send(vocabulary_request_json(song: song, request_id: input[:request_id]))

        Failure(Response::ApiResult.new(
                  status: :processing,
                  message: { request_id: input[:request_id], msg: PROCESSING_MSG }
                ))
      rescue StandardError => e
        App.logger.error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      def vocabulary_request_json(input)
        Response::VocabularyRequest.new(input[:song], input[:request_id])
          .then { Representer::VocabularyRequest.new(_1) }
          .then(&:to_json)
      end

      def find_song_details(input)
        song = Repository::For.klass(Entity::Song).find_origin_id(input[:origin_id])
        unless song.vocabulary.empty?
          # puts "vocabulary: #{song}"
          return Success(Response::ApiResult.new(status: :created, message: song))
        end

        Success(song: song, request_id: input[:request_id])
      rescue StandardError => e
        App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      # def check_song_eligibility(input_song)
      # return Failure(Response::ApiResult.new(status: :not_found, message: NO_SONG_ERR)) unless input_song.nil?
      #  Success(input_song)
      # end

      def request_vocabulary_factory_worker(input)
        Messaging::Queue.new(App.config.VOCABULARY_QUEUE_URL, App.config)
          .send(vocabulary_request_json(song: input[:song], request_id: input[:request_id]))

        Failure(Response::ApiResult.new(
                  status: :processing,
                  message: { request_id: input[:request_id], msg: PROCESSING_MSG }
                ))
      end
    end
  end
end
