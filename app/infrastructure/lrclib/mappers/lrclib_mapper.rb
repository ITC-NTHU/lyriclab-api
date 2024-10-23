# frozen_string_literal: true

module LrclibMapper
  require_relative './lrclib/lrc_api'
  require_relative 'lyrics_mapper'
  require 'json'

  # initialize Lrclib API information
  def self.initialize_api(track_name, artist_name)
    @lrclib_api = LyricLab::Lrclib::Api.new(track_name, artist_name)
    @lyrics_mapper = LyricLab::Lrclib::LyricsMapper.new(track_name, artist_name)
  end

  # get song information from Lrclib  API
  def self.map_lyrics_from_lrclib(track_name, artist_name)
    initialize_api(track_name, artist_name)
    lyrics_entity = @lyrics_mapper.search
    parse_lyrics(lyrics_entity) if lyrics_entity
  end

  # transfer Lrclib JSON format into lyrics_entity
  def self.parse_lyrics(lyrics_entity)
    {
      text: lyrics_entity.text
    }
  end
end
