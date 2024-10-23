# frozen_string_literal: true

module LyricLab
  module Lrclib
    # Data Mapper: LrcLib -> Lyrics entity
    class LyricsMapper
      def initialize(title, artist, gateway_class = LyricLab::Lrclib::Api)
        @title = title
        @artist = artist
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@title, @artist)
      end

      def search
        data = @gateway.lyric_data
        LyricsMapper.build_entity(data)
      end

      def self.build_entity(data)
        DataMapper.new(data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          LyricLab::Entity::Lyrics.new(
            text:text
          )
        end

        private

        def text
          @data['plainLyrics']
        end
      end
    end
  end
end
