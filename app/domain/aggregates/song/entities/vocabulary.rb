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
      option :raw_text, default: proc { '' }
      option :vocabulary_factory, default: proc {}

      attr_accessor :unique_words, :sep_text

      def to_attr_hash
        {
          sep_text:, raw_text:
        }
      end

      def generate_content
        raise 'Vocabulary already populated' if !unique_words.empty? && sep_text
        raise 'No text to generate vocabulary' if raw_text.empty?
        raise 'No vocabulary factory' if vocabulary_factory.nil?

        unique_word_strings = separate_words(raw_text)

        database_word_objects, api_words = @vocabulary_factory.separate_existing_and_new_words(unique_word_strings)
        api_word_data = @vocabulary_factory.generate_words_metadata(api_words)
        api_word_objects = @vocabulary_factory.build_words_from_hash(api_word_data)
        unique_word_objects = database_word_objects.concat(api_word_objects)
        @sep_text = sep_text
        @unique_words = unique_word_objects

        self.unique_words = unique_words
      end

      def separate_words(raw_text)
        text = vocabulary_factory.convert_to_traditional(raw_text)
        @sep_text = vocabulary_factory.extract_separated_text(text)
        @sep_text.split.map(&:strip).reject(&:empty?).uniq
      end
    end
  end
end
