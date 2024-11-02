# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LyricLab
  module Entity
    # Domain Entity for Songs
    class Recommendation < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :title, Strict::String
      attribute :artist_name_string, Strict::String
      attribute :search_cnt, Strict::Integer

      def to_attr_hash
        to_hash.except(:id)
      end

      def increment_search_counter
        self.search_cnt += 1
        Database::RecommendationRepository.new.update(self)
      end
    end
  end
end
