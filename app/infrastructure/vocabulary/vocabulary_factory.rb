# frozen_string_literal: true

require 'json'
module LyricLab
  module Vocabulary
    # Data Factory: Vocabulary from lyrics text
    class VocabularyFactory
      include Mixins::WordProcessor
      def initialize(openai_api)
        @gpt = GptWordProcessorStub.new(openai_api)
      end

      def create_vocabulary_from_text(text, language_level)
        text = Mixins::WordProcessor.convert_to_traditional(text)
        filtered_words = extract_words_from_text(text, language_level)
        Entity::Vocabulary.new(
          language_level:,
          filtered_words:
        )
      end

      def create_filtered_words_from_text(text, language_level)
        text = Mixins::WordProcessor.convert_to_traditional(text)
        extract_words_from_text(text, language_level)
      end

      def extract_words_from_text(text, language_level)
        words = @gpt.extract_words(text)
        filtered_words = Mixins::WordProcessor.filter_relevant_words(words, language_level.to_sym)

        # check which words we already have in the database
        database_word_objects, gpt_words = filter_existing_and_new_words(filtered_words)

        gpt_word_data = @gpt.get_words_metadata(gpt_words)
        # gpt_word_data should be a list of hashes in this format:
        # [{
        # characters:,
        # pinyin:,
        # translation:,
        # word_type:,
        # example_sentence: db_record.example_sentence}]
        gpt_word_objects = Repository::Words.rebuild_many_from_hash(gpt_word_data)

        database_word_objects.concat(gpt_word_objects)
      end

      def filter_existing_and_new_words(words)
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
