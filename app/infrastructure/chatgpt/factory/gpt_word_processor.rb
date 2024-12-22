# frozen_string_literal: true

module LyricLab
  module OpenAI
    # line credit calculation methods
    class GptWordProcessor
      def initialize(openai)
        # do something
        @openai = openai
      end

      # def extract_words(text)
      #   # should return a list of unique words extracted by ChatGPT
      #   extract_message = [
      #     { role: 'system', content: '你是一個專業的繁體中文老師，可以從文本中提取有意義的繁體中文詞彙單位' },
      #     { role: 'user', content: "Extract every single unique traditional chinese word from the following text:
      #   reply in this format (one word per line):
      #   你好
      #   風
      #   雲
      #   天空

      #   #{text}" }
      #   ]

      #   response = @openai.chat_response(extract_message)
      #   response.split("\n")

      #   response.split("\n")
      #     .map(&:strip)
      #     .reject(&:empty?)
      #     .uniq

      #   # puts "Extracted words:"
      #   # puts words
      # end

      def extract_separated_text(text)
        # should return a list of unique words extracted by ChatGPT
        extract_message = [
          { role: 'system', content: '你是一個專業的繁體中文老師，可以從文本中提取有意義的繁體中文詞彙單位，務必確認文本中的每個文字都有被分割成有意義的詞彙單位' },
          { role: 'user', content: "Separate all the words in the following text from each other and:
        reply in this format (words separated by spaces):
        你好 風 雲 天空 I am cool

        #{text}" }
        ]
        puts "Extracting separated text from: #{text}"
        response = @openai.chat_response(extract_message)
        puts "Extracted separated text: #{response}"
        response
      end

      require 'concurrent'

      def get_many_words_metadata(input_words)
        promises = input_words.each_slice(30).map do |words_slice|
          Concurrent::Promise.execute { get_words_metadata(words_slice) }
        end

        promises.flat_map(&:value)
      end

      def get_words_metadata(input_words) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        message = [
          { role: 'system', content: '現在你是一名繁體中文老師，要指導外國人學習中文，分析以下文字，務必確認文本中的每個詞彙都有被解釋到，確保每個Difficulty都有10個詞彙：' },
          { role: 'user', content: "Please identify these words and respond in this format:
            Word:繁體中文字
            Translate:English translation ONLY
            Pinyin:標註聲調的拼音
            Difficulty: select one of those：beginner、novice1、novice2、level1、level2、level3、level4, level5
            Definition: English detailed translation ONLY
            Word type:[選擇詞性：N,V,Adj,Adv,Pron,Prep,Conj,Num,Int,Classifier,Idiom,Other]
            Example:[實用的20字內繁體中文例句]

            Focus on words that would be valuable for language learners. Keep example sentences natural and practical.
            It is important that you send the metadata for all #{input_words.length} in a single response)

            Words: #{input_words}" }
        ]

        words = []

        begin
          puts "Generate Words metadata prompt: #{message}"
          response = @openai.chat_response(message)
          puts "Generated Words metadata:#{response}"
          words = []
          current_word = {}
          raise 'No response from GPT' if response.nil? || response.empty?

          response.split("\n").each do |line|
            line = line.strip
            case line
            when /^Word:\s*(.+)/
              words << current_word if current_word[:characters]
              current_word = { characters: ::Regexp.last_match(1) }
            when /^Translate:\s*(.+)/
              current_word[:translation] = ::Regexp.last_match(1) || 'unknown'
            when /^Pinyin:\s*(.+)/
              current_word[:pinyin] = ::Regexp.last_match(1) || 'unknown'
            when /^Difficulty:\s*(.+)/
              current_word[:language_level] = ::Regexp.last_match(1) || nil
            when /^Definition:\s*(.+)/
              current_word[:definition] = ::Regexp.last_match(1) || 'unknown'
            when /^Word type:\s*(.+)/
              current_word[:word_type] = ::Regexp.last_match(1) || 'unknown'
            when /^Example:\s*(.+)/
              current_word[:example_sentence] = ::Regexp.last_match(1) || 'No example provided'
            end
          end

          words << current_word if current_word[:characters]

          words.map! do |word|
            word[:translation] ||= 'unknown'
            word[:pinyin] ||= 'unknown'
            word[:language_level] ||= nil
            word[:definition] ||= 'unknown'
            word[:word_type] ||= 'unknown'
            word[:example_sentence] ||= 'No example provided'
            word
          end
        rescue StandardError => e
          puts "analysis error：#{e.message}"

          words = []
        end

        words
      end

      def create_word_entity(word_data)
        Entity::Word.new(
          id: nil,
          characters: word_data[:characters],
          pinyin: word_data[:pinyin] || 'unknown',
          translation: word_data[:translation] || 'unknown',
          example_sentence: word_data[:example_sentence] || 'No example provided',
          language_level: word_data[:language_level] || nil,
          definition: word_data[:definition] || 'No definition provided',
          word_type: word_data[:word_type] || 'unknown'
        )
      end
    end
  end
end
