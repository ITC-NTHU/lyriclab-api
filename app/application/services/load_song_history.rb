# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Transaction to store project from Github API to database
    class LoadSongHistory
      include Dry::Transaction

      step :load_songs_from_database
      step :create_song_view_objects

      private

      def load_songs_from_database(input)
        puts input.length
        if input.empty?
          Failure('no sessions')
        else
          songs = input.map! do |spotify_id|
              load_song_from_database(spotify_id)
          end
          Success(songs)
        end

        #songs = input.map! do |spotify_id|
        #  load_song_from_database(spotify_id)
        #end
        #Success(songs)
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        Failure(e.to_s)
      end

      def create_song_view_objects(input)
        view_songs = input.map do |song|
          Views::Song.new(song)
        end
        Success(view_songs)
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        Failure(e.to_s)
      end

      def load_song_from_database(spotify_id)
        Repository::For.klass(Entity::Song).find_spotify_id(spotify_id)
      end
    end
  end
end
