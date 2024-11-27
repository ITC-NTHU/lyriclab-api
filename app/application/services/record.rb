# frozen_string_literal: true

require 'dry/monads'

module LyricLab
  module Service
    # Updates the recommendation record in the db
    class RecordRecommendation
      # TODO: @Irina make this a proper dry-transaction file (see other services), is the class name correct?(also change the file name?)
      include Dry::Monads::Result::Mixin

      def call(origin_id)
        puts('start recording ..')
        song = Service::LoadSong.new.call(origin_id)

        if song.failure?
          puts 'song loading failed'
          raise 'song loading failed'
        end
        puts("loaded successful: #{song.inspect}")
        song = song.value!.message
        puts("record recommendation: #{song.inspect}")
        recommendation = Entity::Recommendation.new(song.title, song.artist_name_string, song.origin_id,
                                                    song.vocabulary.language_difficulty)
        Repository::For.entity(recommendation).create(recommendation)
        Success(Response::ApiResult.new(status: :ok, message: recommendation))
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        puts(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: 'having trouble updating recommendations'))
      end
    end

    # class RecordRecommendation # start converting code to transaction script
    #   include Dry::Transaction

    #   step :load_song_from_db
    #   step :load_recommendation_from_db
    #   step :save_recommendation_to_db

    #   def load_song_from_db(origin_id)
    #     song = Service::LoadSong(origin_id)

    #     if (song.failure?)
    #       raise "Problem Loading the Song"
    #     end
    #   end
    # end
  end
end
