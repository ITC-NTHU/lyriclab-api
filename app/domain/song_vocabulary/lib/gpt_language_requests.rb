# frozen_string_literal: true

require_relative '../entities/song'
require_relative '../entities/word'
require_relative '../entities/vocabulary'

module LyricLab
  module Mixins
    # Analyze lyrics using ChatGPT
    module GptLanguageRequests
      # initialize with openai client and path to level mapping
      def initialize(openai, level_mapping_path)
        @openai = openai
        @level_mapping_path = level_mapping_path
        load_level_mapping
      end

      # should get vocabulary after filtering from google api
      def get_vocabulary(song)
        # Check if the song has valid lyrics for processing
        unless song.lyrics&.relevant?
          puts "Skipping vocabulary generation: Song doesn't have valid Mandarin lyrics"
          return nil
        end

        # Check if lyrics text is empty
        if song.lyrics.text.nil? || song.lyrics.text.empty?
          puts "Skipping vocabulary generation: Lyrics text is empty"
          return nil
        end

        message = [
          { role: 'system', content: 'You are a professional Chinese language teacher. Please analyze the vocabulary in these lyrics.' },
          { role: 'user', content: "Please identify the vocabulary in these lyrics and respond in this format:
            Word:[Chinese characters]
            translate:[English translation]
            Pinyin:[pinyin with tone marks]
            Definition:[detailed definition in Chinese]
            Example:[example sentence in Chinese]
            Example Pinyin:[pinyin for the example sentence]
            Example English: [English translation of the example sentence]

            Focus on words that would be valuable for language learners. Keep example sentences natural and practical.
            
            Lyrics: #{song.lyrics.text}" }
        ]

        begin
          response = @openai.chat_response(message)

          # Convert response to array of words
          words = []
          current_word = {}

          response.split("\n").each do |line|
            line = line.strip
            if line.start_with?("Word:")
              # before analyze new word, we should add previous word to words array
              if current_word[:characters]
                words << create_word_entity(current_word)
              end
              # Start a new word
              current_word = { characters: line.split(":")[1]&.strip }
            elsif line.start_with?("English:")
              current_word[:english] = line.split(":")[1]&.strip
            elsif line.start_with?("Pinyin:")
              current_word[:pinyin] = line.split(":")[1]&.strip
            elsif line.start_with?("Definition:")
              current_word[:translation] = combine_definitions(
                current_word[:english],
                line.split(":")[1]&.strip
              )
            elsif line.start_with?("Example Mandarin:")
              current_word[:example_sentence_mandarin] = line.split(":")[1]&.strip
            elsif line.start_with?("Example Pinyin:")
              current_word[:example_sentence_pinyin] = line.split(":")[1]&.strip
            elsif line.start_with?("Example English:")
              current_word[:example_sentence_english] = line.split(":")[1]&.strip
            end
          end

          # Add the last word
          if current_word[:characters]
            words << create_word_entity(current_word)
          end

          # Filter words by target level
          filtered_words = filter_words_by_level(words, target_level)
          puts "Found #{filtered_words.length} words of #{target_level} level"

          # Return nil if no words match the target level
          if filtered_words.empty?
            puts "No vocabulary words found for level: #{target_level}"
            return nil
          end

          # Determine level based on vocabulary mapping
          vocabulary_level = determine_language_level(words)
          Entity::Vocabulary.new(
            id: nil,
            language_level: vocabulary_level,
            words: words
          )
        rescue StandardError => e
          puts "Error processing GPT response: #{e.message}"
          nil
        end
      end

      private

      def filter_words_by_level(words, target_level)
        words.select do |word|
          @word_levels[word.characters] == target_level
        end
      end

      def create_word_entity(word_data)
        Entity::Word.new(
          id: nil,
          characters: word_data[:characters],
          pinyin: word_data[:pinyin] || 'unknown',
          translation: word_data[:translation] || 'unknown',
          example_sentence_mandarin: word_data[:example_sentence_mandarin] || 'No example provided',
          example_sentence_pinyin: word_data[:example_sentence_pinyin] || 'No pinyin provided',
          example_sentence_english: word_data[:example_sentence_english] || 'No translation provided'
        )
      end

      def combine_definitions(english, chinese)
        parts = []
        parts << english if english
        parts << chinese if chinese
        parts.join(" | ")
      end

      def load_level_mapping
        # TODO: should add something for level mapping(EXCEL)
        @word_levels = {}
      rescue StandardError => e
        puts "Error loading level mapping file: #{e.message}"
        @word_levels = {}  # Use empty hash if loading fails
      end
    end
  end
end