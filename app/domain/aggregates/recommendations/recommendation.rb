# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LyricLab
  module Entity
    # Domain Entity for Songs
    class Recommendation
      attr_accessor :spotify_id, :search_cnt, :artist_name_string, :title

      def initialize(title, artist_name_string, search_cnt, spotify_id)
        @title = title
        @artist_name_string = artist_name_string
        @search_cnt = search_cnt
        @spotify_id = spotify_id
      end

      def to_attr_hash
        {
          title: @title,
          artist_name_string: @artist_name_string,
          search_cnt: @search_cnt,
          spotify_id: @spotify_id
        }
      end

      def increment_search_counter
        Repository::Recommendations.new.increment_cnt(@spotify_id)
      end
    end
  end
end
