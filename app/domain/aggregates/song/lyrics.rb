# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LyricLab
  module Entity
    # Domain entity for lyrics
    class Lyrics 

      def initialize(text, is_mandarin, unique_words)
        @text = text
        @is_mandarin = is_mandarin
        @unique_words = unique_words
      end



      #def to_attr_hash
      #  to_hash.except(:id)
      #end

      # TODO
      # should extract unique words on repository level

    end
  end
end
