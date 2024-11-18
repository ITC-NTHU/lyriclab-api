# frozen_string_literal: true
require 'roar/decorator'
require 'roar/json'
require_relative 'recommendation_representer'

module LyricLab
  module Representer
    # Represents list of recommendations
    class ListRecommendations < Roar::Decorator
      include Roar::JSON
      
      collection :recommendations, extend: Representer::Recommendation, class: OpenStruct

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