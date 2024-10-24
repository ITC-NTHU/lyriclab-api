# frozen_string_literal: true

require_relative 'spec_helper'
require_relative 'helpers/vcr_helper'

CORRECT = YAML.safe_load_file(File.join(__dir__, 'fixtures', 'spotify_results.yml'))

describe 'Test Spotify API library' do
  before do
    VcrHelper.configure_vcr_for_spotify
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Song information' do
    it 'HAPPY: should provide correct song attributes' do
      song = LyricLab::Spotify::SongMapper
             .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET)
             .find(SONG_NAME)
      _(song.title).must_equal CORRECT['song_name']
      # _(song.artists[0].name).must_equal CORRECT['artist_name'] TODO check for artist_name_string
      _(song.popularity).must_equal CORRECT['popularity']
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        LyricLab::Spotify::SongMapper
          .new(SPOTIFY_CLIENT_ID, 'BAD_CLIENT_SECRET_ID')
          .find(SONG_NAME)
      end).must_raise LyricLab::Spotify::Api::Response::BadRequest
    end
  end
end
