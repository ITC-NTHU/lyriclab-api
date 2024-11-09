# frozen_string_literal: true

require_relative 'record'

module Views
  # View for a a list of project entities
  class SongsList
    def initialize(recommendations)
      @recommendations = recommendations.map do |rec|
        Record.new(rec)
      end
    end

    def each(&show)
      @recommendations.each do |rec|
        show.call rec
      end
    end

    def any?
      @recommendations.any?
    end
  end
end
