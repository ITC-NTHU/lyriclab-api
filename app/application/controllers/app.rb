# frozen_string_literal: true

require 'rack' # for Rack::MethodOverride
require 'roda'
require 'slim'
require 'slim/include'

module LyricLab
  # Web App
  class App < Roda
    # plugin :sessions, secret: config.SESSION_SECRET
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css', js: 'table_row.js'
    plugin :common_logger, $stderr
    plugin :halt

    use Rack::MethodOverride # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :halt

    # Constants
    SPOTIFY_CLIENT_ID = LyricLab::App.config.SPOTIFY_CLIENT_ID
    SPOTIFY_CLIENT_SECRET = LyricLab::App.config.SPOTIFY_CLIENT_SECRET
    GOOGLE_CLIENT_KEY = LyricLab::App.config.GOOGLE_CLIENT_KEY
    GPT_API_KEY = LyricLab::App.config.GPT_API_KEY

    MESSAGES = {
      empty_search: 'Empty search query',
      songs_not_found: 'Please search for another song',
      # songs_exist : 'Songs already exist',
      not_mandarin_songs: 'Please search for a Mandarin song',
      no_lyrics_found: 'No lyrics found for this song'
    }.freeze

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

            if search_string.empty?
              flash[:error] = MESSAGES[:empty_search]
              response.status = 400
              routing.redirect '/'
            end

            # Get song info from APIs
            # song = Spotify::SongMapper
            #  .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
            #  .find(search_string)

            search_results = []
            begin
              search_results = Spotify::SongMapper
                .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
                .find_n(search_string, 2)
            rescue StandardError
              flash[:error] = MESSAGES[:songs_not_found]
              routing.redirect '/'
            end

            # TODO: check relevancy
            session[:search_result_ids] = search_results.map(&:spotify_id)
            puts search_results.map(&:spotify_id).join

            # Add song to database if it doesn't already exist
            search_results.map { |song| Repository::For.entity(song).create(song) }

            # unless song
            #  flash[:error] = MESSAGES[:songs_not_found]
            #  routing.redirect '/'
            # end

            # unless search_results.map { |song| song.lyrics.is_mandarin }
            #  flash[:error] = MESSAGES[:not_mandarin_songs]
            #  routing.redirect '/'
            # end

            search_results.each do |song|
              unless song.lyrics.is_mandarin
                flash[:error] = MESSAGES[:not_mandarin_songs]
                routing.redirect '/'
              end
            end

            # Redirect viewer to search results page
            routing.redirect "search/search_results/#{search_results.map(&:spotify_id).join}" if search_string
          end
        end

        routing.on 'search_results', String do |_search_ids|
          routing.get do
            search_results = session[:search_result_ids].map do |id|
              Repository::For.klass(Entity::Song).find_spotify_id(id)
            end
            viewable_search_results = Views::SongsList.new(search_results)
            view 'suggestion', locals: { suggestions: viewable_search_results }
          end
        end

        routing.on 'result', String do |spotify_id|
          routing.get do
            # Get song from database
            song = Repository::For.klass(Entity::Song).find_spotify_id(spotify_id)

            unless song
              flash[:error] = MESSAGES[:empty_search]
              routing.redirect '/'
            end

            # create recommendation
            recommendation = Entity::Recommendation.new(song.title, song.artist_name_string, 1, song.spotify_id)
            Repository::For.entity(recommendation).create(recommendation)

            song.vocabulary.gen_unique_words(song.lyrics.text, GPT_API_KEY)
            puts "Vocabulary: #{song.vocabulary.inspect}"
            viewable_song = Views::Song.new(song)

            # Show viewer the song
            view 'song', locals: { song: viewable_song }
          end
        end
      end
    end
  end
end
