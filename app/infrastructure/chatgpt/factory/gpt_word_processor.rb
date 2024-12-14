# frozen_string_literal: true

module LyricLab
  module OpenAI
    # line credit calculation methods
    class GptWordProcessor
      def initialize(openai)
        # do something
        @openai = openai
      end

      # def extract_words(text) # rubocop:disable Metrics/MethodLength
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

        @openai.chat_response(extract_message)
      end

      def get_words_metadata(input_words) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        message = [
          { 
            role: 'system', 
            content: '你現在是一名繁體中文老師，專門指導外國人學習繁體中文。你的目標是逐一解析文本中的每個詞，並提供結構化的回覆資訊，確保每個詞都完整處理，且格式統一。' 
          },
          { 
            role: 'user', 
            content: <<~MESSAGE
              請逐一解析以下文本中的每一個詞，並以如下格式回傳：
              Word: 繁體中文字
              Translate: English translation ONLY
              Pinyin: 標註聲調的拼音
              Difficulty: 選擇以下之一：beginner、novice1、novice2、level1、level2、level3、level4、level5
              Definition: English detailed translation ONLY
              Word type: 選擇詞性：N,V,Adj,Adv,Pron,Prep,Conj,Classifier,Idiom,Other
              Example: 實用的20字內繁體中文例句
              
              請一次完整返回以下文本中每一個詞的解析資訊，並按照詞在文本中出現的順序依次回覆。
              
              重要：文本可能較長，但請一次回覆所有詞彙的解析資訊，不要讓我再問第二次。
              
              文本如下：
              #{input_words}
            MESSAGE
          }
        ]
      

        words = []
      
        begin
     
          response = @openai.chat_response(
            model: "gpt-4o-mini",
            messages: message,
            temperature: 1.0,         
            max_tokens: 15000,        
            top_p: 1.0,               
            frequency_penalty: 0.0,   
            presence_penalty: 0.0     
          )
      
          
          raise "API doesn't reply" if response.nil? || response.empty?
      
         
          current_word = {}
      
          
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
