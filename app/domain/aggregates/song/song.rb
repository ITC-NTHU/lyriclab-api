# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'lyrics'
require_relative 'vocabulary'

module LyricLab
  module Entity
    # Domain Entity for Songs
    class Song 

      def initialize(title, artist_name_string, lyrics, is_instrumental)
        @title = title
        @artist_name_string = artist_name_string
        @lyrics = lyrics
        @is_instrumental = is_instrumental
      end

      def initialize_vocabulary(language_level)
        @vocabulary = Vocabulary.new(language_level, @lyrics.unique_words)
      end

      def relevant?
        !@is_instrumental and @lyrics.is_mandarin
      end
    end
  end
end
