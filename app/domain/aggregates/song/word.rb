# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LyricLab
  module Entity
    # Value Entitiy for Word
    class Word < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :characters, Strict::String
      attribute :translation, Strict::String
      attribute :pinyin, Strict::String
      attribute :word_type, Strict::String.optional
      attribute :example_sentence, Strict::String

      def to_attr_hash
        to_hash.except(:id)
      end
    end
  end
end
