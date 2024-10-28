# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'lyrics'

module LyricLab
  module Entity
    # Domain Entity for Songs
    class Song < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :title, Strict::String
      attribute :spotify_id, Strict::String
      attribute :popularity, Strict::Integer
      attribute :preview_url, Strict::String.optional
      attribute :album_name, Strict::String
      attribute :artist_name_string, Strict::String
      attribute :cover_image_url_big, Strict::String.optional
      attribute :cover_image_url_medium, Strict::String.optional
      attribute :cover_image_url_small, Strict::String.optional
      attribute :lyrics, Lyrics
      attribute :explicit, Strict::Bool

      def to_attr_hash
        to_hash.except(:id, :lyrics)
      end

      def relevant?
        lyrics.relevant?
      end

      def increment_search_counter
        self.search_counter += 1
        Database::SongRepository.new.update(self)
      end
    end
  end
end
