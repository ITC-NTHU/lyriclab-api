# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require 'dry-initializer'

require_relative '../values/word'

module LyricLab
  module Entity
    class Vocabulary
      extend Dry::Initializer

      option :id, proc(&:to_i), optional: true
      option :language_level, proc(&:to_s), optional: true
      option :filtered_words, default: proc { [] }

      attr_accessor :language_level, :filtered_words

      def to_attr_hash
        {
          language_level: language_level,
        }
      end

      def gen_filtered_words(text)
        raise 'Language Level hasn\'t been defined yet' if language_level.nil?
        self.filtered_words = LyricLab::Vocabulary::VocabularyFactory.new.create_filtered_words_from_text(text, language_level)
      end
    end
  end
end
