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

    route do |r|
      r.assets

      spotify_api = Spotify::Api.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])
      lrclib_api = LrclibApi::Api.new

      # GET /
      r.root do
        view 'home'
      end

      # GET /search
      r.on 'search' do
        r.get do
          query = r.params['query']
          if query
            begin
              spotify_result = spotify_api.track_data(query)
              track = spotify_result['tracks']['items'].first
              if track
                @song = Entity::Song.new(
                  title: track['name'],
                  artists: track['artists'].map { |artist| Entity::Artist.new(name: artist['name']) },
                  popularity: track['popularity'],
                  album: Entity::Album.new(
                    name: track['album']['name'],
                    cover_image_url_big: track['album']['images'][0]['url'],
                    cover_image_url_medium: track['album']['images'][1]['url'],
                    cover_image_url_small: track['album']['images'][2]['url']
                  ),
                  preview_url: track['preview_url']
                )
                @songs = [@song]
              else
                @songs = []
              end
            rescue StandardError => e
              flash[:error] = "An error occurred: #{e.message}"
              @songs = []
            end
          else
            @songs = []
          end
          view 'home'
        end
      end

      # GET /songs/:id
      r.on 'songs', String do |id|
        r.get do
          begin
            spotify_result = spotify_api.track_data(id)
            track = spotify_result['tracks']['items'].first
            if track
              @song = Entity::Song.new(
                title: track['name'],
                artists: track['artists'].map { |artist| Entity::Artist.new(name: artist['name']) },
                popularity: track['popularity'],
                album: Entity::Album.new(
                  name: track['album']['name'],
                  cover_image_url_big: track['album']['images'][0]['url'],
                  cover_image_url_medium: track['album']['images'][1]['url'],
                  cover_image_url_small: track['album']['images'][2]['url']
                ),
                preview_url: track['preview_url']
              )
              lyrics_result = lrclib_api.lyric_data(@song.title, @song.artists.first.name)
              @lyrics = Entity::Lyrics.new(lyrics: lyrics_result['lyrics'] || 'Lyrics not found')
              view 'song'
            else
              r.halt(404, 'Song not found')
            end
          rescue StandardError => e
            flash[:error] = "An error occurred: #{e.message}"
            r.redirect '/'
          end
        end
      end
    end
  end
end