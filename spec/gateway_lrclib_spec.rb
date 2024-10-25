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
      @api = LyricLab::Lrclib::LyricsMapper.new
      @api_no_title = LyricLab::Lrclib::LyricsMapper.new
      @api_no_artist = LyricLab::Lrclib::LyricsMapper.new
    end

    it 'HAPPY: should provide correct lyric attributes' do
      lyrics = @api.find(TRACK_NAME, ARTIST_NAME)
      _(lyrics.text).must_equal CORRECT_LYRICS.strip
      refute_nil lyrics.text
    end

    it 'SAD: should raise exception on incorrect song title' do
      _(proc do
        @api_no_title.find('BAD_NAME', ARTIST_NAME)
      end).must_raise LyricLab::Lrclib::Api::Response::NotFound
    end

    it 'SAD: should raise exception on incorrect artist' do
      _(proc do
        @api_no_artist.find(TRACK_NAME, 'NO_ARTIST')
      end).must_raise LyricLab::Lrclib::Api::Response::NotFound
    end
  end
end