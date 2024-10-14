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
      attribute :artist, Strict::Array.of(Artist)
      attribute :popularity, Strict::Integer
      attribute :album, Album
      attribute :preview_url, Strict::String
    end
  end
end
