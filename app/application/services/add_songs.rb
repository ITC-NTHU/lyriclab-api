# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Transaction to store project from Github API to database
    class AddSongs
      include Dry::Transaction

      step :parse_search_string
      step :create_entity
      step :check_relevancy
      step :store_song

      SPOTIFY_CLIENT_ID = LyricLab::App.config.SPOTIFY_CLIENT_ID
      SPOTIFY_CLIENT_SECRET = LyricLab::App.config.SPOTIFY_CLIENT_SECRET
      GOOGLE_CLIENT_KEY = LyricLab::App.config.GOOGLE_CLIENT_KEY

      private

      def parse_search_string(input)
        if input.success?
          search_string = input[:search_query]
          Success(search_string:)
        else
          Failure(input.errors.messages.first)
        end
      end

      def create_entity(input)
        search_results = Spotify::SongMapper
          .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
          .find_n(input[:search_string], 5)
        # check if no lyrics
        songs_with_lyrics = search_results.reject { |song| song.lyrics.nil? }
        if songs_with_lyrics.empty?
          Failure('no lyrics found')
        else
          Success(songs_with_lyrics:)
        end
      end

      def check_relevancy(input)
        relevant_songs = input[:songs_with_lyrics].select(&:relevant?)
        if relevant_songs.empty?
          Failure('songs are not mandarin or have no lyrics')
        else
          Success(relevant_songs:)
        end
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        Failure('Oops something went wrong')
      end

      def store_song(input)
        input[:relevant_songs].each { |song| Repository::For.entity(song).create(song) }
        Success(input[:relevant_songs])
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        Failure('having trouble accessing the database')
      end
    end
  end
end
