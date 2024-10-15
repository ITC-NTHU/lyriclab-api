# frozen_string_literal: true

require 'roda'
require 'yaml'

module LyricLab
  # Configuration for the App
  class App < Roda
    CONFIG = YAML.safe_load_file('config/secrets.yml')
    Spotify_TOKEN = CONFIG['SPOTIFY_CLIENT_ID','SPOTIFY_CLIENT_SECRET']
  end
end