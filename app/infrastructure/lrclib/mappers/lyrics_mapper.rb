# frozen_string_literal: true

module LyricLab
  module Lrclib
    # Data Mapper: LrcLib -> Lyrics entity
    class LyricsMapper
      def initialize(google_client_key, gateway_class = LyricLab::Lrclib::Api)
        @google_client_key = google_client_key
        @gateway_class = gateway_class
        @gateway = @gateway_class.new
      end

      def find(title, artist)
        data = @gateway.lyric_data(title, artist)
        LyricsMapper.build_entity(data, @google_client_key)
      end

      def self.build_entity(data, google_client_key)
        DataMapper.new(data, google_client_key).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, google_client_key)
          @data = data
          @language = LyricLab::Google::Api.new(google_client_key)
        end

        def build_entity
          LyricLab::Entity::Lyrics.new(
            id: nil,
            text:,
            is_instrumental:,
            is_mandarin:,
            unique_words:
          )
        end

        private

        def is_instrumental
          @data['instrumental']
        end

        def text
          @data['plainLyrics']
        end

        def is_mandarin
          data = @language.fetch_response(text)
          return true unless data != "zh-TW"
          return false
        end

        def unique_words
          # TODO implement ChatGPT api part
          ['好', '不好', '還好']
        end
      end
    end
  end
end
