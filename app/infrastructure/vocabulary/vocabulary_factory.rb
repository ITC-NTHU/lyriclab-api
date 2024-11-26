# frozen_string_literal: true

require 'json'
module LyricLab
  module Vocabulary
    # Data Factory: Vocabulary from lyrics text
    class VocabularyFactory
      include Mixins::WordProcessor
      def initialize(openai_api)
        @gpt = OpenAI::GptWordProcessor.new(openai_api)
      end

      def create_unique_words_from_text(text)
        text = Mixins::WordProcessor.convert_to_traditional(text)
        extract_words_from_text(text)
      end

      def extract_words_from_text(text)
        sep_text = @gpt.extract_separated_text(text)
        sep_text = Mixins::WordProcessor.convert_to_traditional(sep_text)
        unique_words = sep_text.split.map(&:strip).reject(&:empty?).uniq
        # TODO: get sep_text
        # filtered_words = Mixins::WordProcessor.filter_relevant_words(words, language_level.to_sym)

        # check which words we already have in the database
        puts "unique_words: #{unique_words}"
        database_word_objects, gpt_words = separate_existing_and_new_words(unique_words)
        puts "database_word_objects: #{database_word_objects}, gpt_words: #{gpt_words}"
        gpt_word_data = @gpt.get_words_metadata(gpt_words)
        puts "gpt_word_data: #{gpt_word_data}"
        # gpt_word_data should be a list of hashes that contains all the desired attributes of words
        gpt_word_objects = Repository::Words.rebuild_many_from_hash(gpt_word_data)
        puts "gpt_word_objects: #{gpt_word_objects.inspect}"
        [database_word_objects.concat(gpt_word_objects), sep_text]
      end

      def separate_existing_and_new_words(words) # rubocop:disable Metrics/MethodLength
        existing_word_objects = []
        new_words = []
        words.each do |word|
          db_word = Repository::Words.find_by_characters(word)
          if db_word.nil?
            new_words << word
          else
            existing_word_objects << db_word
          end
        end
        [existing_word_objects, new_words]
      end
    end
  end
end
