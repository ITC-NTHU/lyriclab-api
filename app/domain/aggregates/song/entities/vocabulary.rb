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

      attr_accessor :unique_words

      def to_attr_hash
        {}
      end

      def gen_unique_words(text, openai_api_key)
        openai_api = LyricLab::OpenAI::API.new(openai_api_key)
        voc_factory = LyricLab::Vocabulary::VocabularyFactory.new(openai_api)
        self.unique_words = voc_factory.create_unique_words_from_text(text)
      end
    end
  end
end
