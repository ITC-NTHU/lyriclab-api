# frozen_string_literal: true
require 'bundler/setup'
Bundler.require(:default, :test)

require 'yaml'

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'
require 'vcr'
require 'webmock'

# For lrclib_API
require_relative '../lib/lrclib_api'
SONG_TTL = '好不容易'
ARTIST_NAME = '告五人'
CORRECT = YAML.safe_load(File.read(File.join(__dir__, 'fixtures', 'lyrics-success-results.yml')))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'lrclib_api'
