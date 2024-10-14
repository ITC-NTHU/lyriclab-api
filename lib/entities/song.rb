# frozen_string_literal: true

require_relative 'lyrics'
require_relative 'album'

module LyricLab
  class Song
    def initialize(song_data, data_source)
      @song = song_data
      @data_source = data_source
      @album = Album.new(@song['tracks']['items'][0]['album'])
      @lyrics = LrclibApi.new.song_lyrics(name, artist_name)
    end

    def name
      @song['tracks']['items'][0]['name']
    end

    def artist_name
      @song['tracks']['items'][0]['artists'][0]['name']
    end

    def popularity
      @song['tracks']['items'][0]['popularity']
    end

    def preview_url
      @song['tracks']['items'][0]['preview_url']
    end

  end
end
