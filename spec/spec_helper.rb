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

# For lrclib_API
require_relative '../require_app'
require_app

TRACK_NAME = '好不容易'
ARTIST_NAME = '告五人'
CORRECT = YAML.safe_load_file(File.join(__dir__, 'fixtures', 'lyrics-success-results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'lrclib_api'

# For spotify_API
require_relative '../lib/spotify_api'
CASSETTE_FILE_SP = 'spotify_api'
