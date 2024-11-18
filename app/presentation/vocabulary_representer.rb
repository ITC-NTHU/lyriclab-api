# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module LyricLab
  module Representer
    # Represents essential Vocabulary information for API output
    # USAGE:
    #   Vocabulary = Database::VocabularyOrm.find(1)
    #   Representer::Vocabulary.new(vocabulary).to_json
    class Vocabulary < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia

      property :unique_words
      property :sep_text

      link :self do
        "/api/v1/vocabularies/#{options[:spotify_id]}" 
      end

      link :related_songs do
        "/api/v1/vocabularies/#{options[:spotify_id]}"
      end
    end
  end
end