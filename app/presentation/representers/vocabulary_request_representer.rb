# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'song_representer'

module LyricLab
  module Representer
    # Representer object for project clone requests
    class VocabularyRequest < Roar::Decorator
      include Roar::JSON

      property :song, extend: Representer::Song, class: OpenStruct # rubocop:disable Style/OpenStructUse
      # property :song, extend: Representer::Song, class: Struct
      property :id
    end
  end
end
