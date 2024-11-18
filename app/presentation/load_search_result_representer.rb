# frozen_string_literal: true
require 'roar/decorator'
require 'roar/json'
require_relative 'song_representer'

module LyricLab
  module Representer
    # Represents a list of song history
    class LoadSongHistory < Roar::Decorator
      include Roar::JSON
      
      collection :songs, extend: Representer::Song, class: OpenStruct

      link :self do
        "/api/v1/recommendations"
      end

      link :search do
        "/api/v1/search_results?search_query={query}"
      end

      link :vocabularies do |options|
        "/api/v1/vocabularies/{spotify_id}"
      end
    end
  end
end