# frozen_string_literal: false

require_relative 'helpers/spec_helper'
require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'

describe 'Integration test of word processing and GPT to test vocabulary functions' do
  VcrHelper.setup_vcr

  before do 
    DatabaseHelper.wipe_database
    VcrHelper.configure_vcr_for_spotify
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve song data, generate Vocabulary' do
    # add MOck class for test
     class MockOpenAI
      def chat_response(messages)
        if messages.to_s.include?('Extract unique')
          "山裡\n大海\n為何\n結局\n少年\n未來"
        else
          [
            "Word:山裡\nTranslate:In the mountains\nPinyin:shān lǐ\nDifficulty:level1\nDefinition:Located in the mountains\nWord type:N\nExample:我們去山裡露營",
            "Word:大海\nTranslate:Ocean\nPinyin:dà hǎi\nDifficulty:novice1\nDefinition:The ocean or sea\nWord type:N\nExample:我喜歡看大海"
          ].join("\n\n")
        end
      end

      def chat(parameters: {})
        OpenStruct.new(
          "choices" => [
            OpenStruct.new(
              "message" => OpenStruct.new(
                "content" => chat_response(parameters[:messages])
              )
            )
          ]
        )
      end
    end



    it 'HAPPY: should be able to get song data from Spotify and add filtered_words to vocabulary' do
        mock_openai = MockOpenAI.new

        song = LyricLab::Spotify::SongMapper
              .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY, mock_openai)
              .find(SONG_NAME)

        song.vocabulary.language_level = 'novice1'
        song.vocabulary.gen_filtered_words(song.lyrics.text)

      _(song.vocabulary.filtered_words).wont_be_empty
      # puts "Words: #{song.vocabulary.filtered_words.map{|word| word.inspect}}"
      filtered_words = song.vocabulary.filtered_words
      _(filtered_words.map(&:characters)).must_include '山裡'
      _(filtered_words.map(&:characters)).must_include '大海'
      _(song.vocabulary.language_level).must_equal('novice1')

    end

    it 'HAPPY: should be able to persist vocabulary to database' do
        mock_openai = MockOpenAI.new
        song = LyricLab::Spotify::SongMapper
              .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY, mock_openai)
              .find(SONG_NAME)

        song.vocabulary.language_level = 'novice1'
        song.vocabulary.gen_filtered_words(song.lyrics.text)
      # puts "Before: #{LyricLab::Database::VocabularyOrm.all[-1].filtered_words.first.characters}"
      # puts "Before: LL #{song.vocabulary.language_level}"
      # puts "Before: Words #{song.vocabulary.filtered_words.first.characters}"
      # puts "test: #{song.vocabulary.inspect}"
      _(song.vocabulary.filtered_words).wont_be_empty
      rebuilt = LyricLab::Repository::For.entity(song).create(song)
      # puts "After: Words #{LyricLab::Database::VocabularyOrm.all[-1].filtered_words.first.characters}"
      # puts "After: LL #{LyricLab::Database::VocabularyOrm.all[-1].language_level}"

        _(rebuilt.vocabulary.language_level).must_equal(song.vocabulary.language_level)
        _(rebuilt.vocabulary.filtered_words).wont_be_empty
        db_words = rebuilt.vocabulary.filtered_words
        _(db_words.map(&:characters)).must_include '山裡'
        _(db_words.map(&:characters)).must_include '大海'
    end
  end
end