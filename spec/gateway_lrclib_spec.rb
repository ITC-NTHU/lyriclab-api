# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Tests lrclib API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Lyric information' do
    before do
      @api = LyricLab::Lrclib::LyricsMapper.new(TRACK_NAME, ARTIST_NAME)
      @api_no_title = LyricLab::Lrclib::LyricsMapper.new('BAD_NAME', ARTIST_NAME)
      @api_no_artist = LyricLab::Lrclib::LyricsMapper.new(TRACK_NAME, 'NO_ARTIST')
    end

    it 'HAPPY: should provide correct lyric attributes' do
      lyrics = @api.search
      _(lyrics.text).must_equal CORRECT
      refute_nil lyrics.text
    end

    it 'SAD: should raise exception on incorrect song title' do
      _(proc do
        @api_no_title.search
      end).must_raise LyricLab::Lrclib::Api::Response::NotFound
    end

    it 'SAD: should raise exception on incorrect artist' do
      _(proc do
        @api_no_artist.search
      end).must_raise LyricLab::Lrclib::Api::Response::NotFound
    end
  end
end
