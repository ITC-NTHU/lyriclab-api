# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'bundler/setup'
Bundler.require(:default, :test)

require 'yaml'

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../require_app'
require_app

# For lrclib_API
SONG_TTL = '好不容易'
ARTIST_NAME = '告五人'
CORRECT = YAML.safe_load_file(File.join(__dir__, 'fixtures', 'lyrics-success-results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'lrclib_api'

# For spotify_API
CASSETTE_FILE_SP = 'spotify_api'
SONG_NAME = '山海'
ARTIST = 'No Party For Cao Dong'
ALBUM = '醜奴兒'
RELEASE_DATE = '2016-02-19'
DURATION = '251053'
CONFIG = YAML.safe_load_file(File.expand_path('../config/secrets.yml', __dir__))
SPOTIFY_CLIENT_ID = CONFIG['SPOTIFY_CLIENT_ID']
SPOTIFY_CLIENT_SECRET = CONFIG['SPOTIFY_CLIENT_SECRET']
