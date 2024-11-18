# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module LyricLab
  module Representer
    # Represents essential Recommendation information for API output
    # USAGE:
    #   recommendation = Entity::Recommendation.new(...)
    #   Representer::Recommendation.new(recommendation).to_json
    class Recommendation < Roar::Decorator
      include Roar::JSON

      property :title
      property :artist_name_string
      property :search_cnt
      property :spotify_id

      link :self do
        "api/v1/recommendations/#{spotify_id}"
      end

      link :lyrics do
        "api/v1/recommendations/#{spotify_id}/lyrics"
      end

      link :related do
        "api/v1/recommendations/#{spotify_id}/related"
      end

      link :spotify do
        "https://open.spotify.com/track/#{spotify_id}"
      end

      collection :represented, extend: Representer::Recommendation, class: OpenStruct if respond_to?(:represented)
    end
  end
end