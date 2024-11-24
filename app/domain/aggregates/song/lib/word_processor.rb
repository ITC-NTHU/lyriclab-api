# frozen_string_literal: true

require 'tradsim'
module LyricLab
  module Mixins
    # word processing methods
    module WordProcessor
      LANGUAGE_LEVELS = %i[beginner novice1 novice2 level1 level2 level3 level4 level5].freeze

      def self.filter_relevant_words(words, language_level)
        # should return a list where the irrelevant words are removed
        raise ArgumentError, "Invalid language level: #{language_level}" unless LANGUAGE_LEVELS.include?(language_level)

        word_list = App.merged_word_list[0...App.list_indexes[LANGUAGE_LEVELS.index(language_level)]]
        words.filter do |word|
          !word_list.include?(word)
        end
      end

      # TODO: no need to convert to traditional since we receive taiwanese songs
      def self.convert_to_traditional(text)
        Tradsim.to_trad(text)
      end
    end
  end
end
