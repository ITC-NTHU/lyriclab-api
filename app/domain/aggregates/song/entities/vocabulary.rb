# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative '../values/word'

module LyricLab
  module Entity
    # Domain Entity for Vocabulary
    class Vocabulary < Dry::Struct
      include Dry.Types

      def initialize(language_level, unfiltered_words)
        @language_level = language_level
        @filtered = to_filter(unfiltered_words)
        @words = @filtered.map { |word_string| Value::Word.new(word_string) }
      end

      #def to_attr_hash
      #  to_hash.except(:id, :words)
      #end

      def to_filter(unfiltered)
        # returns list of strings
        ['好', '不好']
      end

      # TODO
      #implement filtering and adding word item

    end
  end
end
