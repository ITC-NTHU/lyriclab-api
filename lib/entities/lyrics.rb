# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LyricLab
  module Entity
    # Domain entity for lyrics
    class Lyrics < Dry::Struct
      include Dry.Types
      attribute :lyrics, Strict::String
    end
  end
end
