# frozen_string_literal: true

require_relative 'spec_helper'
require_relative 'helpers/vcr_helper'

describe 'Tests lrclib API library' do
  before do
    VcrHelper.configure_vcr_for_lrclib
  end

  after do
    VcrHelper.eject_vcr
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
