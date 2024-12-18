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

      LANGUAGE_LEVELS = %i[beginner novice1 novice2 level1 level2 level3 level4 level5].freeze
      LEVEL_WEIGHT = {
        beginner: 1,
        novice1: 2,
        novice2: 2,
        level1: 3,
        level2: 3,
        level3: 5,
        level4: 6,
        level5: 7
      }.freeze

      option :id, proc(&:to_i), optional: true
      option :unique_words, default: proc { [] }
      option :sep_text, default: proc { '' }
      option :raw_text, default: proc { '' }
      option :vocabulary_factory, default: proc {}
      option :language_difficulty, proc(&:to_f), optional: true
      # language_difficulty 0: beginner -> 7: level5

      def to_attr_hash
        {
          sep_text:, raw_text:, language_difficulty:
        }
      end

      def empty?
        @unique_words.empty? || @sep_text.empty? || language_difficulty.nil?
      end

      def calculate_language_difficulty_from_unique_words
        raise 'Vocabulary not populated' if @unique_words.empty?

        level_counts = {}
        LANGUAGE_LEVELS.each do |level|
          level_counts[level] = @unique_words.map do |word|
            word.language_level.strip.to_sym == level
          end.count(true)
        end

        diff_sum_with_weights, word_num_with_weights = get_word_stats_with_weight(level_counts)

        @language_difficulty = diff_sum_with_weights.to_f / word_num_with_weights
      end

      def get_word_stats_with_weight(level_counts)
        diff_sum_with_weights = level_counts.reduce(0) do |sum, (level, count)|
          sum + (LANGUAGE_LEVELS.index(level) * count * LEVEL_WEIGHT[level])
        end
        word_num_with_weights = level_counts.reduce(0) do |sum, (level, count)|
          sum + (count * LEVEL_WEIGHT[level])
        end
        [diff_sum_with_weights, word_num_with_weights]
      end

      def generate_content # rubocop:disable Metrics/AbcSize
        raise 'Vocabulary already populated' if !@unique_words.empty? && sep_text
        raise 'No text to generate vocabulary' if @raw_text.nil?
        raise 'No vocabulary factory' if @vocabulary_factory.nil?

        @raw_text = @vocabulary_factory.convert_to_traditional(@raw_text)
        yield 'extracting' if block_given?
        unique_word_strings = separate_words(@raw_text)
        yield 'filtering' if block_given?
        database_word_objects, api_words = @vocabulary_factory.separate_existing_and_new_words(unique_word_strings)
        yield 'processing' if block_given?
        api_word_data = @vocabulary_factory.generate_words_metadata(api_words)
        api_word_data = clean_difficulty_levels(api_word_data)
        yield 'finalizing' if block_given?
        api_word_objects = @vocabulary_factory.build_words_from_hash(api_word_data)

        @unique_words = database_word_objects.concat(api_word_objects)

        calculate_language_difficulty_from_unique_words unless @unique_words.empty?
      end

      def clean_difficulty_levels(api_word_data_list)
        api_word_data_list.each do |word_data|
          word_data[:language_level] = word_data[:language_level].gsub(/[^a-z0-9]/, '')
        end
        api_word_data_list
      end

      def separate_words(raw_text)
        text = vocabulary_factory.convert_to_traditional(raw_text)
        @sep_text = vocabulary_factory.extract_separated_text(text)
        @sep_text.split.map(&:strip).reject(&:empty?).uniq
      end
    end
  end
end
