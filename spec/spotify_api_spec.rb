# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative '../lib/spotify_api'

SONG_NAME = '山海'
ARTIST = 'No Party For Cao Dong'
ALBUM = '醜奴兒'
RELEASE_DATE = '2016-02-19'
DURATION = '251053'
CONFIG = YAML.safe_load_file(File.expand_path('../../config/secrets.yml', __FILE__))
SPOTIFY_CLIENT_ID = CONFIG['SPOTIFY_CLIENT_ID']
SPOTIFY_BEARER_TOKEN = CONFIG['SPOTIFY_BEARER_TOKEN']
CORRECT = YAML.safe_load_file(File.join(__dir__, 'fixtures', 'spotify_results.yml'))


describe 'Test Spotify API library' do
  describe 'Song information' do
    before do
      @spotify_api = GoodName::SpotifyApi.new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET)
    end

    it 'HAPPY: should provide correct song attributes' do
      song = @spotify_api.song(SONG_NAME)
      _(song.name).must_equal CORRECT['song_name']
      _(song.artist_name).must_equal CORRECT['artist_name']
      _(song.popularity).must_equal CORRECT['popularity']
      _(song.preview_url).must_equal CORRECT['preview_url']
    end

    it 'SAD: should raise exception on incorrect song' do
      _(proc do
       @spotify_api.song('ERRORsong')
      end).must_raise GoodName::SpotifyApi::Response::NotFound
    end

    it 'SAD: should raise exception when unauthorized ' do
      bad_api = GoodName::SpotifyApi.new(SPOTIFY_CLIENT_ID, 'BAD_CLIENT_SECRET_ID')
      _(proc do
        bad_api.song(SONG_NAME)
      end).must_raise GoodName::SpotifyApi::Response::Unauthorized
    end
  end
end
