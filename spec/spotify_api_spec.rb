# frozen_string_literal: true

require_relative 'spec_helper'

SONG_NAME = '山海'
ARTIST = 'No Party For Cao Dong'
ALBUM = '醜奴兒'
RELEASE_DATE = '2016-02-19'
DURATION = '251053'
CONFIG = YAML.safe_load_file(File.expand_path('../config/secrets.yml', __dir__))
SPOTIFY_CLIENT_ID = CONFIG['SPOTIFY_CLIENT_ID']
SPOTIFY_CLIENT_SECRET = CONFIG['SPOTIFY_CLIENT_SECRET']
CORRECT = YAML.safe_load_file(File.join(__dir__, 'fixtures', 'spotify_results.yml'))

describe 'Test Spotify API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.before_record do |i|
      i.response.headers.delete('Set-Cookie')
      i.request.headers.delete('Authorization')

      u = URI.parse(i.request.uri)
      i.request.uri.sub!(%r{://.*#{Regexp.escape(u.host)}}, "://#{u.host}")
    end

    c.filter_sensitive_data('<REDACTED>') { SPOTIFY_CLIENT_ID }
    c.filter_sensitive_data('<REDACTED>') { CGI.escape(SPOTIFY_CLIENT_ID) }
    c.filter_sensitive_data('<REDACTED>') { SPOTIFY_CLIENT_SECRET }
    c.filter_sensitive_data('<REDACTED>') { CGI.escape(SPOTIFY_CLIENT_SECRET) }

    c.filter_sensitive_data('<REDACTED>') do |interaction|
      token_match = /"access_token":"(.*?)"/.match(interaction.response.body)
      token_match[1] if token_match
    end
  end

  before do
    VCR.insert_cassette CASSETTE_FILE_SP,
                        record: :new_episodes,
                        match_requests_on: %i[method uri body headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Song information' do
    before do
      @spotify_api = GoodName::SpotifyApi.new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET)
      @bad_api = GoodName::SpotifyApi.new(SPOTIFY_CLIENT_ID, 'BAD_CLIENT_SECRET_ID')
    end

    it 'HAPPY: should provide correct song attributes' do
      song = @spotify_api.song(SONG_NAME)
      _(song.name).must_equal CORRECT['song_name']
      _(song.artist_name).must_equal CORRECT['artist_name']
      _(song.popularity).must_equal CORRECT['popularity']
    end

    # DISCLAIMER: SPOTIFY will always return a song even though garbage is passed in
    # it 'SAD: should raise exception on non-existant song' do
    #   _(proc do
    #     @spotify_api.song('8q823yucomwuaenoriuq932qcnui9273298572985792837wrcoinwhdfiskHrpiq2uawerh9q32h4r')
    #   end).must_raise GoodName::SpotifyApi::Response::NotFound
    # end

    it 'SAD: should raise exception when unauthorized' do
      # bad_api = GoodName::SpotifyApi.new(SPOTIFY_CLIENT_ID, 'BAD_CLIENT_SECRET_ID')
      _(proc do
        @bad_api.song(SONG_NAME)
      end).must_raise GoodName::SpotifyApi::Response::BadRequest
    end
  end
end
