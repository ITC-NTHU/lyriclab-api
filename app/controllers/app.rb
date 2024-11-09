# frozen_string_literal: true

require 'rack'
require 'roda'
require 'slim'
require 'slim/include'

module LyricLab
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css', js: 'table_row.js'
    plugin :common_logger, $stderr

    use Rack::MethodOverride # allows HTTP verbs beyond GET/POST (e.g., DELETE)

    # Constants
    SPOTIFY_CLIENT_ID = LyricLab::App.config.SPOTIFY_CLIENT_ID
    SPOTIFY_CLIENT_SECRET = LyricLab::App.config.SPOTIFY_CLIENT_SECRET
    GOOGLE_CLIENT_KEY = LyricLab::App.config.GOOGLE_CLIENT_KEY

    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      routing.public

      # GET /
      routing.root do
        recommendations = Repository::For.klass(Entity::Recommendation).top_searched_songs

        viewable_recommendations = Views::SongsList.new(recommendations)

        view 'home', locals: { recommendations: viewable_recommendations }
      end

      # GET /search
      routing.on 'search' do
        routing.is do
          # POST /search/
          routing.post do
            search_string = routing.params['search_query']
            # Get song info from APIs
            #song = Spotify::SongMapper
            #  .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
            #  .find(search_string)

            search_results = []
            search_results = Spotify::SongMapper
              .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
              .find_n(search_string, 3)

            # TODO check relevancy
            session[:search_result_ids] = search_results.map(&:spotify_id)
            puts search_results.map(&:spotify_id).join

            # Add song to database if it doesn't already exist
            begin
              search_results.map { |song| Repository::For.entity(song).create(song) }
              #Repository::For.entity(song).create(song)
            rescue StandardError => e
              # Handle the case where the song already exists
              puts "Error: #{e.message}"
            end

            # Redirect viewer to search results page

            routing.redirect "search/search_results/#{search_results.map(&:spotify_id).join}" if search_string
          end
        end

        routing.on 'search_results', String do |search_ids|
          routing.get do
            search_results = session[:search_result_ids].map { |id| Repository::For.klass(Entity::Song).find_spotify_id(id) }
            viewable_search_results = Views::SongsList.new(search_results)
            view 'suggestion', locals: { suggestions: viewable_search_results}
          end 
        end

        routing.on 'result', String do |spotify_id|
          routing.get do
            puts spotify_id
            # Get song from database
            song = Repository::For.klass(Entity::Song).find_spotify_id(spotify_id)

            recommendation = Entity::Recommendation.new(song.title, song.artist_name_string, 1, song.spotify_id)
            Repository::For.entity(recommendation).create(recommendation)

            # Show viewer the song
            view 'song', locals: { song: }
          end
        end
      end
    end
  end
end
