# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module LyricLab
  module Representer
    # Represents essential Lyrics information for API output
    # USAGE:
    #   lyrics = Database::LyricsOrm.find(1)
    #   Representer::Lyrics.new(lyrics).to_json
    class Lyrics < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      
      property :id
      property :text
      property :is_mandarin
      property :is_instrumental

      link :self do
        "api/v1/lyrics/#{id}"
      end

      link :recommendations do
        "api/v1/lyrics/#{id}/recommendations"
      end

      link :translations do
        "api/v1/lyrics/#{id}/translations" if is_mandarin
      end

      collection :represented, extend: Representer::Lyrics, class: OpenStruct if respond_to?(:represented)
    end
  end
end