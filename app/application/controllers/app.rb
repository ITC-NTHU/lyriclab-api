# frozen_string_literal: true

require 'rack' # for Rack::MethodOverride
require 'roda'
require 'slim'
require 'slim/include'

module LyricLab
  # Web App
  class App < Roda
    plugin :sessions, secret: config.SESSION_SECRET
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css', js: 'table_row.js'
    plugin :common_logger, $stderr
    plugin :halt

    use Rack::MethodOverride # allows HTTP verbs beyond GET/POST (e.g., DELETE)

    MSG_GET_STARTED = 'No recommendations found'

    # Constants
    GPT_API_KEY = LyricLab::App.config.GPT_API_KEY

    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      routing.public
      session[:song_history] ||= []

      # GET /
      routing.root do
        viewable_song_history = Service::LoadSongHistory.new.call(session[:song_history])
        viewable_song_history = if viewable_song_history.failure?
                                  []
                                else
                                  viewable_song_history.value!
                                end

        result = Service::ListRecommendations.new.call
        viewable_recommendations = if result.failure?
                                     flash[:error] = result.failure
                                     []
                                   else
                                     Views::SongsList.new(result.value!)
                                   end
        view 'home', locals: { recommendations: viewable_recommendations, song_history: viewable_song_history }
      end

      # GET /search
      routing.on 'search' do
        routing.is do
          # POST /search/
          routing.post do
            search_string = Forms::NewSearch.new.call(routing.params)
            search_results = Service::AddSongs.new.call(search_string)

            if search_results.failure?
              flash[:error] = search_results.failure
              routing.redirect '/'
            end

            songs = search_results.value!
            session[:search_result_ids] = songs.map(&:spotify_id)
            routing.redirect "search/search_results/#{songs.map(&:spotify_id).join}"
          end
        end

        routing.on 'search_results', String do |_search_ids|
          routing.get do
            result = Service::LoadSearchResults.new.call(session[:search_result_ids])
            if result.failure?
              flash[:error] = result.failure
              viewable_search_results = []
            else
              search_results = result.value!
              viewable_search_results = Views::SongsList.new(search_results)
            end

            view 'suggestion', locals: { suggestions: viewable_search_results }
          end
        end

        # GET /result/{spotify_id}
        routing.on 'result', String do |spotify_id|
          routing.get do
            # Get song from database
            song = Service::LoadSong.new.call(spotify_id)
            if song.failure?
              App.logger.error(song.failure)
              flash[:error] = MESSAGES[:no_lyrics_found]
              routing.redirect '/'
            end
            song = song.value!
            session[:song_history] += [song.spotify_id]

            record_result = Service::Record.new.call(song)

            flash[:error] = record_result.failure if record_result.failure?

            vocabulary_song = Service::LoadVocabulary.new.call(song)
            if vocabulary_song.failure?
              App.logger.error(vocabulary_song.failure)
              flash[:error] = MESSAGES[:no_lyrics_found]
              routing.redirect '/'
            else
              vocabulary_song = vocabulary_song.value!
            end
            viewable_song = Views::Song.new(vocabulary_song)

            # Show viewer the song
            view 'song', locals: { song: viewable_song }
          end
        end
      end
    end
  end
end
