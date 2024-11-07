# frozen_string_literal: true

require_relative 'helpers/spec_helper'
require_relative 'helpers/vcr_helper'

describe 'Integration test of word processing and GPT to test vocabulary functions' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_openai
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Extract words' do
    it 'HAPPY: should extract unique words from Mountain Sea lyrics' do
      # Simulate GPT response
      mock_openai = Object.new
      def mock_openai.chat_response(_messages)
        "為何\n轉身\n山裡\n大海\n過去\n美好\n結局\n少年\n聲音\n渴望\n未來"
      end

      processor = LyricLab::GptWordProcessor.new(mock_openai)

      # extract unique words from 山海
      text = '為何 轉身 山裡 大海 過去 美好 結局 少年 聲音 渴望 未來'
      result = processor.extract_words(text)

      _(result).must_be_kind_of Array
      _(result).wont_be_empty
      _(result).must_include '山裡'
      _(result).must_include '大海'
      _(result).must_include '為何'
      _(result).must_include '結局'
      _(result).must_include '少年'
      _(result).must_include '未來'
    end

    it 'HAPPY: should handle empty text' do
      mock_openai = Object.new
      def mock_openai.chat_response(_messages)
        ''
      end

      processor = LyricLab::GptWordProcessor.new(mock_openai)
      result = processor.extract_words('')

      _(result).must_be_kind_of Array
      _(result).must_be_empty
    end
  end

  describe 'Create word entity' do
    it 'HAPPY: should create word entity with complete data' do
      mock_openai = Minitest::Mock.new
      processor = LyricLab::GptWordProcessor.new(mock_openai)

      # words in 山海
      word_data = {
        characters: '山裡',
        pinyin: 'shān lǐ',
        translation: 'in the mountains',
        example_sentence: '我們去山裡露營',
        difficulty: 'level1',
        definition: '在山區或山地中',
        word_type: 'N'
      }

      word = processor.create_word_entity(word_data)

      _(word.characters).must_equal '山裡'
      _(word.pinyin).must_equal 'shān lǐ'
      _(word.translation).must_equal 'in the mountains'
      _(word.example_sentence).must_equal '我們去山裡露營'
      _(word.difficulty).must_equal 'level1'
      _(word.definition).must_equal '在山區或山地中'
      _(word.word_type).must_equal 'N'
    end

    it 'HAPPY: should create word entity with default values for missing data' do
      mock_openai = Object.new
      processor = LyricLab::GptWordProcessor.new(mock_openai)

      word_data = { characters: '大海' }
      word = processor.create_word_entity(word_data)

      _(word.characters).must_equal '大海'
      _(word.pinyin).must_equal 'unknown'
      _(word.translation).must_equal 'unknown'
      _(word.example_sentence).must_equal 'No example provided'
      _(word.difficulty).must_equal 'unknown'
      _(word.definition).must_equal 'No definition provided'
      _(word.word_type).must_equal 'unknown'
    end
  end

  describe 'Get words metadata' do
    it 'HAPPY: should process single word metadata correctly' do
      mock_openai = Object.new
      def mock_openai.chat_response(_messages)
        "Word:未來\n" \
          "Translate:Future\n" \
          "Pinyin:wèi lái\n" \
          "Difficulty:beginner\n" \
          "Definition:Future time or events\n" \
          "Word type:N\n" \
          'Example:讓我們一起期待未來'
      end

      processor = LyricLab::GptWordProcessor.new(mock_openai)

      result = processor.get_words_metadata(['未來'])

      _(result).must_be_kind_of Array
      _(result.length).must_equal 1

      word = result[0]
      _(word[:characters]).must_equal '未來'
      _(word[:pinyin]).wont_be_nil
      _(word[:difficulty]).wont_be_nil
      _(word[:word_type]).wont_be_nil
      _(word[:example_sentence]).wont_be_nil
    end

    it 'HAPPY: should handle multiple words from Mountain Sea lyrics' do
      mock_openai = Object.new
      def mock_openai.chat_response(_messages) # rubocop:disable Metrics/MethodLength
        [
          'Word:山裡',
          'Translate:In the mountains',
          'Pinyin:shān lǐ',
          'Difficulty:level1',
          'Definition:Located in the mountains',
          'Word type:N',
          'Example:我們去山裡露營',
          '', # Separator between words
          'Word:大海',
          'Translate:Ocean',
          'Pinyin:dà hǎi',
          'Difficulty:novice1',
          'Definition:The ocean or sea',
          'Word type:N',
          'Example:我喜歡看大海'
        ].join("\n")
      end

      processor = LyricLab::GptWordProcessor.new(mock_openai)

      result = processor.get_words_metadata(%w[山裡 大海])

      _(result).must_be_kind_of Array
      _(result.length).must_equal 2

      # check for 2 specific words
      mountain = result.find { |w| w[:characters] == '山裡' }
      _(mountain).wont_be_nil
      _(mountain[:word_type]).must_equal 'N'
      _(mountain[:pinyin]).must_equal 'shān lǐ'
      _(mountain[:difficulty]).must_equal 'level1'

      sea = result.find { |w| w[:characters] == '大海' }
      _(sea).wont_be_nil
      _(sea[:word_type]).must_equal 'N'
      _(sea[:pinyin]).must_equal 'dà hǎi'
      _(sea[:difficulty]).must_equal 'novice1'
    end
  end
end
