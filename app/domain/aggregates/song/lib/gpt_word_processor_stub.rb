# frozen_string_literal: true

module LyricLab
  # module ChatGPT
  # TODO put this in the module and in the infrastructure folder

    # line credit calculation methods
    class GptWordProcessorStub

      def initialize(openai)
        # do something
        @openai = openai
      end

      def extract_words(text)
        # should return a list of unique words extracted by ChatGPT
        extract_message =[
        { role: 'system', content: '你是一個專業的繁體中文老師，可以從文本中提取有意義的繁體中文詞彙單位' },
        { role: 'user', content: "Extract unique traditional chinese words from the following text:
        reply in this format (one word per line):
        你好
        風
        雲
        天空

        #{text}" }
        ]

        response = @openai.chat_response(extract_message)
        response.split("\n")

        words = response.split("\n")
          .map(&:strip)
          .reject(&:empty?)
          .uniq
        
        # puts "Extracted words:"
        # puts words
      
        words
      end

      def create_word_entity(word_data)
        Entity::Word.new(
          id: nil,
          characters: word_data[:characters],
          pinyin: word_data[:pinyin] || 'unknown',
          translation: word_data[:translation] || 'unknown',
          example_sentence: word_data[:example_sentence] || 'No example provided',
          difficulty: word_data[:difficulty] || 'unknown',
          definition: word_data[:definition] || 'No definition provided',
          word_type: word_data[:word_type] || 'unknown'
        )
      end

      def get_words_metadata(input_words)

            message = [
          { role: 'system', content: '現在你是一名繁體中文老師，要指導外國人學習中文，分析以下文字：' },
          { role: 'user', content: "Please identify these words and respond in this format:
            Word:[繁體中文字]
            translate:[English translation]
            Pinyin:[標註聲調的拼音]
            Difficulty:[選擇難度：beginner、novice1、novice2、level1、level2、level3、level4 或 level5]
            Definition:[英文的詳細定義]
            Word type:[選擇詞性：N,V,Adj,Adv,Pron,Prep,Conj,Num,Int,Classifier,Idiom,Other]
            Example:[實用的20字內繁體中文例句]

            Focus on words that would be valuable for language learners. Keep example sentences natural and practical.

            Words: #{input_words}" }
        ]



        begin
          # response = @openai.chat_response(message)
          # puts "Raw response from ChatGPT:"
          # puts response
          response = @openai.chat_response(message)
          words = []
          current_word = {}

          response.split("\n").each do |line|
            line = line.strip
            case line
            when /^Word:\s*(.+)/
              words << current_word if current_word[:characters]
              current_word = { characters: $1 }
            when /^Translate:\s*(.+)/
              current_word[:english] = $1
            when /^Pinyin:\s*(.+)/
              current_word[:pinyin] = $1
            when /^Difficulty:\s*(.+)/
              current_word[:difficulty] = $1
            when /^Definition:\s*(.+)/
              current_word[:definition] = $1
              current_word[:translation] = combine_definitions(current_word[:english], $1)
            when /^Word type:\s*(.+)/
              current_word[:word_type] = $1
            when /^Example:\s*(.+)/
              current_word[:example_sentence] = $1
            end
          end

          # Add the last word
          if current_word[:characters]
            words << current_word
          end
        end
        return words
      end

      def combine_definitions(english, chinese)
        parts = []
        parts << english if english
        parts << chinese if chinese
        parts.join(" | ")
      end
    end
end
