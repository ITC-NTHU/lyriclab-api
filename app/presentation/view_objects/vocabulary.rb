# frozen_string_literal: true

require_relative 'word'
require 'slim'

module Views
  # View for a a list of project entities
  class Vocabulary
    def initialize(vocabulary)
      @vocabulary = vocabulary
    end

    def sep_text
      @vocabulary.sep_text
    end

    def unique_words
      @vocabulary.unique_words.map { |word| Views::Word.new(word) }
    end

    def rich_text
      Slim::Template.new('app/presentation/views_html/rich_text.slim')
      .render(Object.new, vocabulary: self)
    end
  end
end
