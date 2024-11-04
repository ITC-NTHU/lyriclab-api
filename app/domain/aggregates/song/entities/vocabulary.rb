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
      option :language_level, proc(&:to_s), optional: true
      option :filtered_words, default: proc { [] }

      attr_accessor :language_level, :filtered_words

      def to_attr_hash
        {
          language_level:
        }
      end

      def gen_filtered_words(text, openai_api_key)
        raise 'Language Level hasn\'t been defined yet' if language_level.nil?

        openai_api = LyricLab::OpenAI.new(openai_api_key)
        voc_factory = LyricLab::Vocabulary::VocabularyFactory.new(openai_api)
        self.filtered_words = voc_factory.create_filtered_words_from_text(text, language_level)
      end
    end
  end
end
