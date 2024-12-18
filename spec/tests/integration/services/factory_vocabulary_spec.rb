# frozen_string_literal: false

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'
require_relative '../../../helpers/simple_cov_helper'

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

    # it 'HAPPY: should be able to get song data from Spotify and add filtered_words to vocabulary' do
    #   song = LyricLab::Spotify::SongMapper
    #     .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
    #     .find(CORRECT_SONG['title'])
    #   LyricLab::Service::SaveSong.new.call(song)
    #   vocabulary_song = LyricLab::Service::LoadVocabulary.new.call(song.origin_id).value!.message
    #   # puts(vocabulary_song.inspect)
    #   _(vocabulary_song.vocabulary.unique_words).wont_be_empty
    # end

    # it 'HAPPY: should be able to persist vocabulary to database' do
    #   song = LyricLab::Spotify::SongMapper
    #     .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
    #     .find(CORRECT_SONG['title'])
    #   LyricLab::Service::SaveSong.new.call(song)
    #   voc_song = LyricLab::Service::LoadVocabulary.new.call(song.origin_id).value!.message
    #   _(voc_song.vocabulary.language_difficulty).wont_be_nil
    #   _(voc_song.vocabulary.language_difficulty.to_i).wont_equal(-1)
    #   # puts "DB vocabulary: #{LyricLab::Database::VocabularyOrm.first.language_difficulty}"
    #   rebuilt = LyricLab::Service::LoadSong.new.call(song.origin_id).value!.message
    #   # puts "rebuilt.vocabulary.unique_words: #{rebuilt.vocabulary.unique_words.first.inspect}"
    #   # puts "rebuilt.vocabulary.language_difficulty: #{rebuilt.vocabulary.language_difficulty}"
    #   _(rebuilt.vocabulary.unique_words).wont_be_empty
    #   _(rebuilt.vocabulary.language_difficulty).wont_be_nil
    #   _(rebuilt.vocabulary.language_difficulty.to_i).wont_equal(-1)
    # end

    it 'HAPPY: should be able to retrieve song vocabulary from a song with vocabulary by origin_id' do
      song = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find(CORRECT_SONG['title'])
      LyricLab::Service::SaveSong.new.call(song)
      LyricLab::Service::GenVocabulary.new.call(song.origin_id)
      6.times do
        sleep(1)
        print('_')
      end
      rebuilt = LyricLab::Service::LoadSong.new.call(song.origin_id).value!.message

      _(rebuilt.vocabulary.unique_words.length).wont_equal(0)
      _(rebuilt.vocabulary.unique_words.first.characters).wont_include('[')
      _(rebuilt.vocabulary.unique_words.first.characters).wont_include(']')
      _(rebuilt.vocabulary.language_difficulty).wont_be_nil
      _(rebuilt.vocabulary.language_difficulty.to_i).wont_equal(-1)
    end

    it 'HAPPY: should be able to retrieve song vocabulary from a song WITHOUT vocabulary by origin_id' do
      song = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find(CORRECT_SONG['title'])
      LyricLab::Service::SaveSong.new.call(song)

      rebuilt = LyricLab::Service::LoadSong.new.call(song.origin_id).value!.message
      _(rebuilt.vocabulary.raw_text).wont_be_empty
      _(rebuilt.vocabulary.unique_words.length).must_equal(0)
      _(rebuilt.vocabulary.sep_text).must_be_empty
      # _(rebuilt.vocabulary.language_difficulty).must_be_nil # TODO why is it 0.0 and not nil?
    end

    it 'HAPPY: should be able to retrieve empty vocabulary from db populate it and then persist' do
      song = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find(CORRECT_SONG['title'])
      LyricLab::Service::SaveSong.new.call(song)

      rebuilt = LyricLab::Service::LoadSong.new.call(song.origin_id).value!.message

      LyricLab::Service::GenVocabulary.new.call(rebuilt.origin_id)

      6.times do
        sleep(1)
        print('_')
      end
      rebuilt2 = LyricLab::Service::GenVocabulary.new.call(song.origin_id)
      _(rebuilt2.failure?).wont_equal true

      rebuilt2 = rebuilt2.value!.message

      _(rebuilt2.vocabulary.unique_words.length).wont_equal(0)
      _(rebuilt2.vocabulary.unique_words.first.characters).wont_be_empty
      _(rebuilt2.vocabulary.language_difficulty.to_i).wont_equal(-1)
      _(rebuilt2.vocabulary.language_difficulty).wont_be_nil
    end

    it 'HAPPY: should be able to update vocabulary entity often without problem' do
      song = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find(CORRECT_SONG['title'])
      LyricLab::Service::SaveSong.new.call(song)
      rebuilt = LyricLab::Service::LoadSong.new.call(song.origin_id).value!.message
      LyricLab::Service::GenVocabulary.new.call(rebuilt.origin_id)
      6.times do
        sleep(1)
        print('_')
      end
      rebuilt = LyricLab::Service::LoadVocabulary.new.call(song.origin_id).value!.message
      # puts rebuilt.vocabulary.unique_words.map(&:language_level)
      LyricLab::Repository::For.entity(rebuilt).update(rebuilt)
      LyricLab::Repository::For.entity(rebuilt).update(rebuilt)
      LyricLab::Repository::For.entity(rebuilt).update(rebuilt)
      LyricLab::Repository::For.entity(rebuilt).update(rebuilt)

      rebuilt2 = LyricLab::Repository::For.klass(LyricLab::Entity::Song).find_origin_id(song.origin_id)

      _(rebuilt2.vocabulary.unique_words.length).wont_equal(0)
      _(rebuilt2.vocabulary.unique_words.length).must_equal(rebuilt.vocabulary.unique_words.length)
      _(rebuilt2.vocabulary.unique_words.first.characters).wont_be_empty
      _(rebuilt2.vocabulary.language_difficulty.to_i).wont_equal(-1)
      _(rebuilt2.vocabulary.language_difficulty).wont_be_nil
    end

    it 'SAD: should not be able to create a song that already exists' do
      song = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find(CORRECT_SONG['title'])
      LyricLab::Service::SaveSong.new.call(song)

      LyricLab::Service::LoadVocabulary.new.call(song.origin_id).value!.message
      rebuilt = LyricLab::Service::LoadSong.new.call(song.origin_id).value!.message
      result = LyricLab::Service::SaveSong.new.call(rebuilt)
      _(result.failure?).wont_be_nil
    end
  end
end
