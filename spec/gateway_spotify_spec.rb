# frozen_string_literal: true

# TODO: check the required changes
require_relative 'spec_helper'

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
    it 'HAPPY: should provide correct song attributes' do
      song = LyricLab::Spotify::SongMapper
             .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET)
             .find(SONG_NAME)
      _(song.title).must_equal CORRECT['song_name']
      _(song.artists[0].name).must_equal CORRECT['artist_name']
      _(song.popularity).must_equal CORRECT['popularity']
    end

    it 'SAD: should raise exception when unauthorized' do
      # bad_api = LyricLab::SpotifyApi.new(SPOTIFY_CLIENT_ID, 'BAD_CLIENT_SECRET_ID')
      _(proc do
        LyricLab::Spotify::SongMapper
          .new(SPOTIFY_CLIENT_ID, 'BAD_CLIENT_SECRET_ID')
          .find(SONG_NAME)
      end).must_raise LyricLab::Spotify::Api::Response::BadRequest
    end
  end
end
