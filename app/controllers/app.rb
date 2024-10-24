# frozen_string_literal: true

require 'roda'
require 'slim'

module LyricLab
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :public, root: 'app/views/public'
    plugin :assets, path: 'app/views/assets',
                    css: 'style.css', js: 'table_row_click.js'
    plugin :common_logger, $stderr
    plugin :halt
    #plugin :flash

    route do |routing| # rubocop:disable Metrics/BlockLength
      routing.assets # load CSS

      # GET /
      routing.root do
        songs = Repository::For.klass(Entity::Song).all
        view 'home', locals: { songs: }
      end

      # GET /search
      routing.on 'search' do
        routing.is do
          # POST /search/
          routing.post do
            search_string = routing.params['search_query']

            # Get song info from APIs
            song = Spotify::SongMapper
                      .new(SP_CLIENT_ID, SP_CLIENT_SECRET)
                      .find(search_string)

            # Add song to database
            Repository::For.entity(song).create(song)

            # Redirect viewer to project page
            routing.redirect "/search/#{song.title}/#{song.artist_name_string}" if search_string
          end
        end

        # GET /search/:query
        routing.on String, String do |title, artist_name|
          routing.get do
            # Get project from database
            song = Repository::For.klass(Entity::Song)
              .find_from_title_artist(title, artist_name)

            # Show viewer the project
            view 'song', locals: { song: }
          end
        end
      end
    end
  end
end
