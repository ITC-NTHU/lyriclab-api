# frozen_string_literal: true

module LyricLab
  module Lrclib
    # Data Mapper: LrcLib -> Lyrics entity
    class LyricsMapper
      def initialize(gateway_class = LyricLab::Lrclib::Api)
        @gateway_class = gateway_class
        @gateway = @gateway_class.new
      end

      def find(title, artist)
        data = @gateway.lyric_data(title, artist)
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
            id: nil,
            is_mandarin: nil,
            text:
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
