# frozen_string_literal: true

require_relative 'helpers/spec_helper'
require_relative 'helpers/vcr_helper'

CORRECT = YAML.safe_load_file(File.join(__dir__, 'fixtures', 'spotify_results.yml'))

describe 'Test Spotify API library' do
  before do
    VcrHelper.configure_vcr_for_spotify
  end

  after do
    VcrHelper.eject_vcr
  end
  describe 'Song information' do
    before do
      @api = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
    end

    it 'HAPPY: should provide correct song attributes' do
      song = @api.find(SONG_NAME)
      _(song.title).must_equal CORRECT['title']
      _(song.artist_name_string).must_equal CORRECT['artist_name_string']
      _(song.popularity).must_equal CORRECT['popularity']
      # _(song.preview_url).must_equal CORRECT['preview_url']
      _(song.album_name).must_equal CORRECT['album_name']
      _(song.cover_image_url_big).must_equal CORRECT['cover_image_url_big']
      _(song.cover_image_url_medium).must_equal CORRECT['cover_image_url_medium']
      _(song.cover_image_url_small).must_equal CORRECT['cover_image_url_small']
      _(song.explicit).must_equal CORRECT['explicit']
    end

    it 'HAPPY: should provide 2 search result songs' do
      songs = @api.find_n(SONG_NAME, 2)
      _(songs.length).must_equal 2
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        LyricLab::Spotify::SongMapper
          .new(SPOTIFY_CLIENT_ID, 'BAD_CLIENT_SECRET_ID', GOOGLE_CLIENT_KEY)
          .find(SONG_NAME)
      end).must_raise LyricLab::Spotify::Api::Response::BadRequest
    end
  end
end
