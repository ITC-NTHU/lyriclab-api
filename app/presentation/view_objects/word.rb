# frozen_string_literal: true

module Views
  # View for a a list of project entities
  class Word
    def initialize(word)
      @word = word
    end

    def vocabulary_info
      view :vocabulary_info, locals: { word: @word }
    end

    def characters
      @word.characters
    end

    def translation
      @word.translation
    end
  end
end
