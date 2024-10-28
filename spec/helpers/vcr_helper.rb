# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
module VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  LRCLIB_CASSETTE = 'lrclib_api'
  SPOTIFY_CASSETTE = 'spotify_api'

  def self.setup_vcr
    VCR.configure do |config|
      config.cassette_library_dir = CASSETTES_FOLDER
      config.hook_into :webmock
    end
  end

  def self.configure_vcr_for_spotify
    VCR.configure do |config|
      config.cassette_library_dir = CASSETTES_FOLDER
      config.hook_into :webmock

      config.before_record do |i|
        i.response.headers.delete('Set-Cookie')
        i.request.headers.delete('Authorization')

        u = URI.parse(i.request.uri)
        i.request.uri.sub!(%r{://.*#{Regexp.escape(u.host)}}, "://#{u.host}")
      end

      config.filter_sensitive_data('<REDACTED>') { SPOTIFY_CLIENT_ID }
      config.filter_sensitive_data('<REDACTED>') { CGI.escape(SPOTIFY_CLIENT_ID) }
      config.filter_sensitive_data('<REDACTED>') { SPOTIFY_CLIENT_SECRET }
      config.filter_sensitive_data('<REDACTED>') { CGI.escape(SPOTIFY_CLIENT_SECRET) }

      config.filter_sensitive_data('<REDACTED>') do |interaction|
        token_match = /"access_token":"(.*?)"/.match(interaction.response.body)
        token_match[1] if token_match
      end
    end

    VCR.insert_cassette(
      SPOTIFY_CASSETTE,
      record: :new_episodes,
      match_requests_on: %i[method uri body headers]
    )
  end

  def self.configure_vcr_for_lrclib
    VCR.insert_cassette(
      LRCLIB_CASSETTE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
