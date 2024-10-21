# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LyricLab
  module Entity
    # Domain Entity for Artists
    class Artist < Dry::Struct
      include Dry.Types

      attribute :name, Strict::String

      def to_attr_hash
        to_hash
      end
    end
  end
end
