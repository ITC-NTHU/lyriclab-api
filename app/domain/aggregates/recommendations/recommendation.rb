# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LyricLab
  module Entity
    # Domain Entity for Songs
    class Recommendation
      attr_accessor :origin_id, :search_cnt, :artist_name_string, :title

      # TODO: @Irina maybe make the attributes read only? (code smell) use attr_reader
      def initialize(title, artist_name_string, search_cnt, origin_id, language_difficulty)
        @title = title
        @artist_name_string = artist_name_string
        @search_cnt = search_cnt
        @origin_id = origin_id
        @language_difficulty = language_difficulty
      end

      def to_attr_hash
        {
          title: @title,
          artist_name_string: @artist_name_string,
          search_cnt: @search_cnt,
          origin_id: @origin_id,
          language_difficulty: @language_difficulty
        }
      end

      def increment_search_counter
        # TODO: @Irina professor said we can not use our infrastructure from the domain entities directly :O
        Repository::Recommendations.new.increment_cnt(@origin_id)
      end
    end
  end
end
