# frozen_string_literal: true

require 'roda'
require 'slim'
require_relative '../models/entities/song'
require_relative '../models/entities/lyrics'
require_relative '../models/entities/album'
require_relative '../models/entities/artist'
require_relative '../models/gateways/lrclib_api'
require_relative '../models/gateways/spotify_api'

module LyricLab
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :common_logger, $stderr
    plugin :halt
    plugin :flash

    route do |current|
      current.assets

      # GET /
      current.root do
        view 'home'
      end

      # GET /search
      current.on 'search' do
        current.is do
          # POST /search/
          current.post do
            search_string = current.params['search_query']
            current.redirect "/search/#{search_string}" if search_string
            current.redirect '/'
          end
        end

        # GET /search/:query
        current.on String do |query|
          current.get do
            song = Spotify::SongMapper
                   .new(SP_CLIENT_ID, SP_CLIENT_SECRET)
                   .find(query)
            lyrics = Lrclib::LyricsMapper
                     .new(song.title, song.artists.first.name)
                     .search
            view 'song', locals: { song:, lyrics: }
          end
        end
      end
    end
  end
end
