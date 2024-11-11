# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LyricLab
  module Entity
    # Domain entity for lyrics
    class Lyrics < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :text, Strict::String
      attribute :is_mandarin, Strict::Bool.optional
      attribute :is_instrumental, Strict::Bool.optional

      def to_attr_hash
        to_hash.except(:id)
      end
    end
  end
end
