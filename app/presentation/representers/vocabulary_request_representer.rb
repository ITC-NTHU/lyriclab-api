# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'song_representer'

module LyricLab
  module Representer
    # Representer object for project clone requests
    class VocabularyRequest < Roar::Decorator
      include Roar::JSON

      property :song, extend: Representer::Song, class: OpenStruct
      property :id
    end
  end
end