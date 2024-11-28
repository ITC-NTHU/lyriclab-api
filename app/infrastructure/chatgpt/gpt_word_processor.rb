# frozen_string_literal: true

module LyricLab
  module OpenAI
    # line credit calculation methods
    class GptWordProcessor
      def initialize(openai)
        # do something
        @openai = openai
      end

      def extract_words(text) # rubocop:disable Metrics/MethodLength
        # should return a list of unique words extracted by ChatGPT
        extract_message = [
          { role: 'system', content: '你是一個專業的繁體中文老師，可以從文本中提取有意義的繁體中文詞彙單位' },
          { role: 'user', content: "Extract every single unique traditional chinese word from the following text:
        reply in this format (one word per line):
        你好
        風
        雲
        天空

        #{text}" }
        ]

        response = @openai.chat_response(extract_message)
        response.split("\n")

        response.split("\n")
          .map(&:strip)
          .reject(&:empty?)
          .uniq

        # puts "Extracted words:"
        # puts words
      end

      def extract_separated_text(text)
        # should return a list of unique words extracted by ChatGPT
        extract_message = [
          { role: 'system', content: '你是一個專業的繁體中文老師，確保將文本中的每一個字都分開成有意義的詞彙' },
          { role: 'user', content: "Separate all the words in the following text from each other and:
            reply in this format (words separated by spaces and should keep original new line format):
            城市 滴答 小巷 滴答 沉默 滴答
            你 的 手 慢熱的 體溫
            方向 錯亂 天氣預報 不準

        #{text}" }
        ]

        @openai.chat_response(extract_message)
      end

      def get_words_metadata(input_words) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
        max_retries = 3;
        input_words_list = input_words.split(' ').reject(&:empty?).uniq
        retry_count = 0;

        message = [
          { role: 'system', content: '現在你是一名繁體中文老師，要指導外國人學習中文，分析文本中的每一個詞彙，且每個Difficulty level都至少有兩個詞彙：' },
          { role: 'user', content: "Please identify these words and respond in this format:
            Word:繁體中文字
            translate:English translation ONLY
            Pinyin:標註聲調的拼音
            Difficulty:select one of those：beginner、novice1、novice2、level1、level2、level3、level4, level5
            Definition:English detailed translation ONLY
            Word type:選擇詞性：N,V,Adj,Adv,Pron,Prep,Conj,Num,Int,Classifier,Idiom,Other
            Example:實用的20字內繁體中文例句

            Focus on words that would be valuable for language learners. Keep example sentences natural and practical.

            Words: #{input_words}" }
        ]

        begin
          # response = @openai.chat_response(message)
          # puts "Raw response from ChatGPT:"
          # puts response
          loop do
            response = @openai.chat_response(message)
            words = []
            current_word = {}
            has_unknown = false

            response.split("\n").each do |line|
              line = line.strip
              case line
              when /^Word:\s*(.+)/
                  if current_word[:characters]
                    has_unknown = check_for_unknowns(current_word)
                    words << current_word unless has_unknown
                  end
                  current_word = { characters: ::Regexp.last_match(1) }
              when /^Translate:\s*(.+)/
                # current_word[:english] = ::Regexp.last_match(1)
                current_word[:translation] = ::Regexp.last_match(1)
              when /^Pinyin:\s*(.+)/
                current_word[:pinyin] = ::Regexp.last_match(1)
              when /^Difficulty:\s*(.+)/
                current_word[:language_level] = ::Regexp.last_match(1)
              when /^Definition:\s*(.+)/
                current_word[:definition] = ::Regexp.last_match(1)
                # current_word[:translation] = combine_definitions(current_word[:english], ::Regexp.last_match(1))
              when /^Word type:\s*(.+)/
                current_word[:word_type] = ::Regexp.last_match(1)
              when /^Example:\s*(.+)/
                current_word[:example_sentence] = ::Regexp.last_match(1)
              end
            end

            if current_word[:characters]
              has_unknown = check_for_unknowns(current_word)
              words << current_word unless has_unknown
            end
            processed_words = words.map { |word| word[:characters] }
            missing_words = input_words_list - processed_words

            difficulty_counts = count_difficulty_levels(words)
            insufficient_difficulties = check_difficulty_distribution(difficulty_counts)

            if (has_unknown||!missing_words.empty? || !insufficient_difficulties.empty? )&& retry_count < max_retries
              retry_count +=1
              message = create_retry_message(words,input_word,missing_words,insufficient_difficulties)
              next
            end

            if retry_count >= max_retries && (has_unknown || !missing_words.empty? || !insufficient_difficulties.empty?)
              Rails.logger.warn("Unable to get complete information after #{max_retries} retries.")
              Rails.logger.warn("Missing words: #{missing_words.join(', ')}") unless missing_words.empty?
              Rails.logger.warn("Insufficient difficulty levels: #{insufficient_difficulties.join(', ')}") unless insufficient_difficulties.empty?
            end

            return words.map do |word|
              word[:translation] ||= 'unknown'
              word[:pinyin] ||= 'unknown'
              word[:language_level] ||= nil
              word[:definition] ||= 'unknown'
              word[:word_type] ||= 'unknown'
              word[:example_sentence] ||= 'No example provided'
              word
            end
          end
        rescue StandardError => e
          Rails.logger.error("Error in get_words_metadata: #{e.message}")
          []
        end
      end

      private

      def check_for_unknowns(word)
        return true if word[:translation]&.downcase == 'unknown' || 
                        word[:pinyin]&.downcase == 'unknown' || 
                        word[:definition]&.downcase == 'unknown' || 
                        word[:word_type]&.downcase == 'unknown'
        false
      end

      def count_difficulty_levels(words)
        words.group_by{|w| w[:language_level]}.transform_values(&:count)
      end

      def check_difficulty_distribution(difficulty_counts)
        difficulty_levels = %w[beginner novice1 novice2 level1 level2 level3 level4 level5]
        difficulty_levels.select{|level| difficulty_counts[level].to_i < 2}
      end

      def create_retry_message(processed_words, original_words, missing_words,insufficient_difficulties)
        retry_message = "Try to provide complete information for these words, ensuring:\n"
        retry_message += "1.Try all missing words: #{missing_words.join(', ')}\n" unless missing_words.empty?
        retry_message += "2.Ensure at least 2 words for each difficulty level:#{insufficient_difficulties.join(', ')}\n" unless insufficient_difficulties.empty?

        processed_characters = processed_words.map { |word| word[:characters] }
        remaining_words = original_words.split(/[,\s]+/).reject{|w| processed_characters.include?(w)}

        [
          { role: 'system', content: '現在你是一名繁體中文老師，要指導外國人學習中文，分析以下文字，確保提供完整的資，不要回傳unknown：' },
          { role: 'user', content: "Please identify these words and respond in this format:
            Word:繁體中文字
            translate:English translation ONLY
            Pinyin:標註聲調的拼音
            Difficulty:select one of those：beginner、novice1、novice2、level1、level2、level3、level4, level5
            Definition:English detailed translation ONLY
            Word type:選擇詞性：N,V,Adj,Adv,Pron,Prep,Conj,Num,Int,Classifier,Idiom,Other
            Example:實用的20字內繁體中文例句

            Please ensure all fields are properly filled out with accurate information.

            Words: #{remaining_words.join(' ')}" }
        ]
      end
    end
  end
end
