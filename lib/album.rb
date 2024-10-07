# frozen_string_literal: true


module GoodName
  class Album
    def initialize(album_data)
      @album = album_data
    end

    def name
      @album['name']
    end

    def cover_image_url_big
      @album['images'][0]['url']
    end

    def cover_image_url_medium
      @album['images'][1]['url']
    end

    def cover_image_url_small
      @album['images'][2]['url']
    end

  end
end
