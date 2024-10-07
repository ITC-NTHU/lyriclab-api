# frozen_string_literal: true

module GoodName
  # provides lyrics
  class Lyrics
    def initialize(lyrics_data, data_source)
      @lyrics = lyrics_data
      @data_source = data_source
    end

    def text
      return @lyrics['plainLyrics'] if @lyrics && @lyrics['plainLyrics']

      'Sorry... no lyrics found(('
    end
  end
end
