# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Generate Vocabulary Data using ChatGPT
    class GenVocabulary
      include Dry::Transaction

      step :find_song_details
      step :check_song_eligibility
      step :request_vocabulary_factory_worker

      private

      DB_ERR = 'Having trouble accessing the database'
      NO_SONG_ERR = 'Song not found'
      PROCESSING_MSG = 'vocabulary generation in progress'

      def find_song_details(input_id)
        # puts 'try to find song in db'
        song = Repository::For.klass(Entity::Song).find_origin_id(input_id)
        # puts "found song: #{song.title}"
        Success(song)
      rescue StandardError => e
        App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      def check_song_eligibility(input_song)
        # return Failure(Response::ApiResult.new(status: :not_found, message: NO_SONG_ERR)) unless input_song.nil?

        Success(input_song)
      end

      def request_vocabulary_factory_worker(input_song)
        unless input_song.vocabulary.empty?
          return Success(Response::ApiResult.new(status: :created,
                                                 message: input_song))
        end

        # puts "add song to queue URL: #{App.config.VOCABULARY_QUEUE_URL} Config: #{App.config}"
        Messaging::Queue
          .new(App.config.VOCABULARY_QUEUE_URL, App.config)
          .send(Representer::Song.new(input_song).to_json)

        Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG))
      end

      #       def populate_vocabulary(input_song)
      #         input_song.vocabulary.generate_content if input_song.vocabulary.unique_words.empty?
      #         Success(input_song)
      #       rescue StandardError => e
      #         App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
      #         Failure(Response::ApiResult.new(status: :internal_error, message: 'cannot generate vocabulary'))
      #       end

      #       def store_vocabulary(input_song)
      #         if Repository::For.entity(input_song).find(input_song)
      #           Repository::For.entity(input_song).update(input_song)
      #         else
      #           Repository::For.entity(input_song).create(input_song)
      #         end
      #         Success(Response::ApiResult.new(status: :ok, message: input_song))
      #       rescue StandardError => e
      #         App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
      #         Failure(Response::ApiResult.new(status: :internal_error, message: 'having trouble writing into db'))
      #       end
    end
  end
end
