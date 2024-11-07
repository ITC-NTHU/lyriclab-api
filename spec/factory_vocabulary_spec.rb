# frozen_string_literal: false

require_relative 'helpers/spec_helper'
require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'

describe 'Integration test of word processing and GPT to test vocabulary functions' do
  VcrHelper.setup_vcr
  before do
    VcrHelper.configure_vcr_for_gpt
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve song data, generate Vocabulary' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to get song data from Spotify and add filtered_words to vocabulary' do
      song = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find(SONG_NAME)
      song.vocabulary.language_level = 'novice1'
      song.vocabulary.gen_filtered_words(song.lyrics.text, OPENAI_API_KEY)

      _(song.vocabulary.filtered_words).wont_be_empty
      # puts "Words: #{song.vocabulary.filtered_words.map(&:inspect)}"
      _(song.vocabulary.language_level).must_equal('novice1')
    end

    it 'HAPPY: should be able to persist vocabulary to database' do
      song = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find(SONG_NAME)
      song.vocabulary.language_level = 'novice1'
      song.vocabulary.gen_filtered_words(song.lyrics.text, OPENAI_API_KEY)
      # puts "Before: #{LyricLab::Database::VocabularyOrm.all[-1].filtered_words.first.characters}"
      # puts "Before: LL #{song.vocabulary.language_level}"
      # puts "Before: Words #{song.vocabulary.filtered_words.first.characters}"
      # puts "test: #{song.vocabulary.inspect}"
      rebuilt = LyricLab::Repository::For.entity(song).create(song)
      # puts "After: Words #{LyricLab::Database::VocabularyOrm.all[-1].filtered_words.first.characters}"
      # puts "After: LL #{LyricLab::Database::VocabularyOrm.all[-1].language_level}"

      _(rebuilt.vocabulary.language_level).must_equal(song.vocabulary.language_level)
      _(rebuilt.vocabulary.filtered_words).wont_be_empty
    end
  end
end
