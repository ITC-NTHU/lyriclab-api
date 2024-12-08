# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
Bundler.require(:default, :test)

require 'yaml'

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../../require_app'
require_app

# For lrclib_API
CASSETTE_FILE = 'lrclib_api'
TRACK_NAME = '好不容易'
ARTIST_NAME = '告五人'
CORRECT_LYRICS = File.read(File.join(__dir__, '../fixtures', 'lyrics-success-results.yml'))

# For spotify_API
CASSETTE_FILE_SP = 'spotify_api'
CORRECT_SONG = YAML.safe_load_file(File.join(__dir__, '../fixtures', 'spotify_results.yml'))

SPOTIFY_CLIENT_ID = LyricLab::App.config.SPOTIFY_CLIENT_ID
SPOTIFY_CLIENT_SECRET = LyricLab::App.config.SPOTIFY_CLIENT_SECRET

# For google_API
GOOGLE_CLIENT_KEY = LyricLab::App.config.GOOGLE_CLIENT_KEY

# For chatgpt_API
GPT_API_KEY = LyricLab::App.config.GPT_API_KEY
