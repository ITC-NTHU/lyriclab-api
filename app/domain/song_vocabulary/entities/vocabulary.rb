# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'word'

module LyricLab
  module Entity
    # Domain Entity for Vocabulary
    class Vocabulary < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :language_level, Strict::String
      attribute :words, Strict::Array.of(Word)

      def to_attr_hash
        to_hash.except(:id, :words)
      end
    end
  end
end
