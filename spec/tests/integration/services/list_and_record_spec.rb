# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

require 'ostruct'

describe 'ListRecommendations and Record Services Integration Test' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_services_record
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Display Top Serached Songs' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should return songs that have been searched' do
      # GIVEN: a valid songs searched and recorded into db
      searched = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find_n(ARTIST_NAME, 5)

      searched.map { |song| LyricLab::Service::Record.new.call(song) }

      # WHEN: we request a list of Top searched songs
      result = LyricLab::Service::ListRecommendations.new.call

      # THEN: we should see songs in recommendation list
      _(result.success?).must_equal true
      song_titles = result.value!.map(&:title)
      searched_titles = searched.map(&:title)
      _(song_titles).must_equal(searched_titles)
    end

    it 'HAPPY: should return top 5' do
      # GIVEN: a valid songs searched (multiple times) and recorded into db
      searched = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find_n(ARTIST_NAME, 5)

      searched.map { |song| LyricLab::Service::Record.new.call(song) }

      sixth_song = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find('No Party For Cao Dong 山海')

      LyricLab::Service::Record.new.call(sixth_song)
      LyricLab::Service::Record.new.call(sixth_song)

      # WHEN: we request a list of Top searched songs
      result = LyricLab::Service::ListRecommendations.new.call

      # THEN: it should return Top 5 songs and include the song searched twice
      _(result.success?).must_equal true
      song_titles = result.value!.map(&:title)
      _(song_titles).must_include '山海'
      _(song_titles.length).must_equal 5
    end
  end
end
