# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module LyricLab
  module Representer
    # Represents essential Song information for API output
    # USAGE:
    #   Song = Database::SongOrm.find(1)
    #   Representer::Song.new(song).to_json
    class Song < Roar::Decorator
      include Roar::JSON

      property :id
      property :title
      property :spotify_id
      property :popularity
      property :preview_url
      property :album_name
      property :artist_name_string
      property :cover_image_url_big
      property :cover_image_url_medium
      property :cover_image_url_small
      property :is_instrumental
      property :vocabulary
      property :lyrics
      property :explicit

      property :vocabulary, extend: Representer::Vocabulary, class: OpenStruct
      property :lyrics, extend: Representer::Lyrics, class: OpenStruct

      link :self do
        "/api/v1/songs/#{id}"
      end

      link :lyrics do
        "/api/v1/songs/#{id}/lyrics"
      end

      link :vocabulary do
        "/api/v1/songs/#{id}/vocabulary"
      end

      link :spotify do
        "https://open.spotify.com/track/#{spotify_id}"
      end

      link :preview do
        preview_url if preview_url
      end
    end
  end
end