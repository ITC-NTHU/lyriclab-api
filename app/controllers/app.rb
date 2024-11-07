# frozen_string_literal: true

require 'rack' # for Rack::MethodOverride
require 'roda'
require 'slim'
require 'slim/include'

module LyricLab
  # Web App
  class App < Roda
    #plugin :sessions, secret: config.SESSION_SECRET
    plugin :render, engine: 'slim', views: 'app/presentation/view_html'
    plugin :public, root: 'app/views/public'
    plugin :assets, path: 'app/views/assets',
                    css: 'style.css', js: 'table_row_click.js'
    plugin :common_logger, $stderr
    plugin :halt

    use Rack::MethodOverride

    # Constants
    SPOTIFY_CLIENT_ID = LyricLab::App.config.SPOTIFY_CLIENT_ID
    SPOTIFY_CLIENT_SECRET = LyricLab::App.config.SPOTIFY_CLIENT_SECRET
    GOOGLE_CLIENT_KEY = LyricLab::App.config.GOOGLE_CLIENT_KEY

    MESSAGES={
      empty_search: 'Please enter a song name',
      songs_not_found: 'Please search for another song',
      # songs_exist : 'Songs already exist',
      not_mandarin_songs: 'Please search for a Mandarin song',
      no_lyrics_found: 'No lyrics found for this song'
  }.freeze

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
           
            unless !search_string.empty?
              flash[:error] = MESSAGES[:empty_search]
              response.status = 400
              routing.redirect '/'
            end

            # Get song info from APIs
            begin
              song = Spotify::SongMapper
                    .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
                    .find(search_string)
            rescue BadRequest  => e
              flash[:error] = MESSAGES[:songs_not_found]
            end

            unless song
              flash[:error] = MESSAGES[:songs_not_found]
              routing.redirect '/'
            end

            unless song.lyrics.is_mandarin
              flash[:error] = MESSAGES[:not_mandarin_songs]
              routing.redirect '/'
            end





            # upload suggestion list to session
            session[:suggestion] ||= []
            session[:suggestion].append(song)
            session[:suggestions] = suggestions

            recommendation = Entity::Recommendation.new(song.title, song.artist_name_string, 1, song.spotify_id)
            Repository::For.entity(recommendation).create(recommendation)
            
            # Add song to database if it doesn't already exist
            begin
              Repository::For.entity(song).create(song)
            rescue StandardError => e # TODO: why error?
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
          suggestions = session[:suggestions] || []
          #puts s
          view 'suggestion', locals: { suggestions: s}
        end 
      end

        # GET /search/:query
        routing.on String, String do |spotify_id, title|
          routing.get do
            # Get song from database
            song = Repository::For.klass(Entity::Song).find_spotify_id(spotify_id)

            unless song
              flash[:error] = MESSAGES[:empty_search]
              routing.redirect '/'
            end

            # Show viewer the song
            view 'song', locals: { song: }
          end
        end
      end
    end
  end
end
