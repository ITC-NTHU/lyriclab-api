# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Generate Vocabulary Data using ChatGPT
    class GenVocabulary
      include Dry::Transaction

      step :united

      private

      DB_ERR = 'Having trouble accessing the database'
      NO_SONG_ERR = 'Song not found'
      PROCESSING_MSG = 'vocabulary generation in progress'

      def united(input)
        song = find_song(input[:origin_id])
        return success_response(song) if song_has_vocabulary?(song)

        send_to_queue(song, input[:request_id])
        processing_response(input[:request_id])
      rescue StandardError => e
        handle_error(e)
      end

      def find_song(origin_id)
        Repository::For.klass(Entity::Song).find_origin_id(origin_id)
      end

      def song_has_vocabulary?(song)
        !song.vocabulary.empty?
      end

      def success_response(song)
        Success(Response::ApiResult.new(status: :created, message: song))
      end

      def send_to_queue(song, request_id)
        Messaging::Queue.new(App.config.VOCABULARY_QUEUE_URL, App.config)
          .send(vocabulary_request_json(song: song, request_id: request_id))
      end

      def processing_response(request_id)
        Failure(Response::ApiResult.new(
                  status: :processing,
                  message: { request_id: request_id, msg: PROCESSING_MSG }
                ))
      end

      def handle_error(error)
        App.logger.error(error)
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      def vocabulary_request_json(input)
        Response::VocabularyRequest.new(input[:song], input[:request_id])
          .then { Representer::VocabularyRequest.new(_1) }
          .then(&:to_json)
      end
    end
  end
end
