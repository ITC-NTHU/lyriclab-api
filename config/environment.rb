# frozen_string_literal: true

require 'roda'
require 'yaml'

module LyricLab
  # Configuration for the App
  class App < Roda
    CONFIG = YAML.safe_load_file('config/secrets.yml')
    SP_CLIENT_ID = CONFIG['SPOTIFY_CLIENT_ID']
    SP_CLIENT_SECRET = CONFIG['SPOTIFY_CLIENT_SECRET']
  end
end
