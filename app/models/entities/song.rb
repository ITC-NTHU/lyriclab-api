# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'lyrics'
require_relative 'album'
require_relative 'artist'

module LyricLab
  module Entity
    # Domain Entity for Songs
    class Song < Dry::Struct
      include Dry.Types

      attribute :title, Strict::String
      attribute :spotify_id, Strict::String
      attribute :popularity, Strict::Integer
      attribute :preview_url, Strict::String
      attribute :album_name, Strict::String
      attribute :artist_name_string, Strict::String
      attribute :cover_image_url_big, Strict::String
      attribute :cover_image_url_medium, Strict::String
      attribute :cover_image_url_small, Strict::String
      attribute :lyrics, Lyrics

      def to_attr_hash
        to_hash
      end
    end
  end
end
