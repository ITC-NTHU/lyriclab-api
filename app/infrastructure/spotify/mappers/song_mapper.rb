# frozen_string_literal: true

require 'json'
module LyricLab
  module Spotify
    # Data Mapper: Spotify -> Song entity
    class SongMapper
      # initialize Spotify API information
      def initialize(client_id, client_secret, google_client_key, gateway_class = Spotify::Api)
        @client_id = client_id
        @client_secret = client_secret
        @google_client_key = google_client_key
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@client_id, @client_secret)
      end

      # get song information from Spotify API
      def find(search_string)
        data = @gateway.track_data(search_string, 1)
        build_entity(data['tracks']['items'].first)
      end

      def find_n(search_string, n)
        data = @gateway.track_data(search_string, n)
        data['tracks']['items'].map { |track_data| build_entity(track_data) }
      end

      def build_entity(data)
        DataMapper.new(data, @client_id, @client_secret, @google_client_key, @gateway_class).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, _client_id, _client_secret,  _google_client_key, _gateway_class)
          @data = data # right now we can only parse a single song
          @lyrics_mapper = LyricLab::Lrclib::LyricsMapper.new(_google_client_key)
        end

        # rubocop:disable Metrics/MethodLength
        def build_entity
          LyricLab::Entity::Song.new(
            id: nil,
            title:,
            artist_name_string:,
            lyrics:,
            spotify_id:,
            popularity:,
            preview_url:,
            album_name:,
            cover_image_url_big:,
            cover_image_url_medium:,
            cover_image_url_small:,
            explicit:
          )
        end
        # rubocop:enable Metrics/MethodLength

        def title
          @data['name']
        end

        def spotify_id
          @data['id']
        end

        def popularity
          @data['popularity']
        end

        def preview_url
          @data['preview_url']
        end

        def album_name
          @data['album']['name']
        end

        def artist_name_string
          @data['artists'].map { |artist_data| artist_data['name'] }.join(', ')
        end

        def cover_image_url_big
          @data['album']['images'][0]['url']
        end

        def cover_image_url_medium
          @data['album']['images'][1]['url']
        end

        def cover_image_url_small
          @data['album']['images'][2]['url']
        end

        def lyrics
          @lyrics_mapper.find(title, artist_name_string)
          # TODO: does it work with artist name string or should be just use a single artist?
        end

        def vocabulary

        end

        def explicit
          @data['explicit']
        end
      end
    end
  end
end
