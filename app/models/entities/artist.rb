# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LyricLab
  module Entity
    # Domain Entity for Artists
    class Artist < Dry::Struct
      include Dry.Types

      attribute :name, Strict::String
    end
  end
end
