# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require 'dry-initializer'

require_relative '../values/word'

module LyricLab
  module Entity
    # Domain entity for vocabulary
    class Vocabulary
      extend Dry::Initializer

      option :id, proc(&:to_i), optional: true
      option :unique_words, default: proc { [] }
      option :sep_text, default: proc { '' }

      attr_accessor :unique_words, :sep_text

      def to_attr_hash
        {
          sep_text:
        }
      end

      def populate_vocabulary(unique_words, sep_text)
        raise 'Vocabulary already populated' if !unique_words.empty? && sep_text

        self.unique_words = unique_words
        self.sep_text = sep_text
      end
    end
  end
end
