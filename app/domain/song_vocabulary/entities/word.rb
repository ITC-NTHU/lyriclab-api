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
      attribute :example_sentence_mandarin, Strict::String
      attribute :example_sentence_pinyin, Strict::String
      attribute :example_sentence_english, Strict::String

      def to_attr_hash
        to_hash.except(:id)
      end
    end
  end
end
