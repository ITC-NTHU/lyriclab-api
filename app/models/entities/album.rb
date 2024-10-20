# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
module LyricLab
  module Entity
    # Domain Entity for Albums
    class Album < Dry::Struct
      include Dry.Types

      attribute :name, Strict::String
      attribute :cover_image_url_big, Strict::String
      attribute :cover_image_url_medium, Strict::String
      attribute :cover_image_url_small, Strict::String
    end
  end
end
