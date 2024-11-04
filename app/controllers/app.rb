# frozen_string_literal: true

require 'roda'
require 'slim'

module LyricLab
  # Web App
  class App < Roda
    #plugin :sessions, secret: config.SESSION_SECRET
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :public, root: 'app/views/public'
    plugin :assets, path: 'app/views/assets',
                    css: 'style.css', js: 'table_row_click.js'
    plugin :common_logger, $stderr
    plugin :halt
    # plugin :flash

    # Constants
    SPOTIFY_CLIENT_ID = LyricLab::App.config.SPOTIFY_CLIENT_ID
    SPOTIFY_CLIENT_SECRET = LyricLab::App.config.SPOTIFY_CLIENT_SECRET
    GOOGLE_CLIENT_KEY = LyricLab::App.config.GOOGLE_CLIENT_KEY


    route do |routing|
      routing.assets # load CSS

      # GET /
      routing.root do
        recommendations = Repository::For.klass(Entity::Recommendation).top_searched_songs
        view 'home', locals: { recommendations: }
      end

      # GET /search
      routing.on 'search' do
        routing.is do
          # POST /search/
          routing.post do
            search_string = routing.params['search_query']
            # Get song info from APIs
            song = Spotify::SongMapper
                   .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
                   .find(search_string)

            suggestions = []
            suggestions = suggestions.append(song)    
            suggestions = suggestions.append(song)
            session[:suggestions] = suggestions

            recommendation = Entity::Recommendation.new(song.title, song.artist_name_string, 1, song.spotify_id)
            Repository::For.entity(recommendation).create(recommendation)
            # Add song to database if it doesn't already exist
            begin
              Repository::For.entity(song).create(song)
            rescue StandardError => e
              # Handle the case where the song already exists
              puts "Error: #{e.message}"
            end

            # Redirect viewer to project page
            #routing.redirect "/search/#{song.spotify_id}/#{song.title}" if search_string
          
            routing.redirect "/search/show-suggestions" if search_string
          end
        end

        # GET /search
      routing.on 'show-suggestions' do
        routing.get do
          s = session[:suggestions]
          #puts s
          view 'suggestion', locals: { suggestions: s}
        end 
      end

        # GET /search/:query
        routing.on String, String do |spotify_id, title|
          routing.get do
            # Get song from database
            song = Repository::For.klass(Entity::Song).find_spotify_id(spotify_id)

            # Show viewer the song
            view 'song', locals: { song: }
          end
        end
      end
    end
  end
end
