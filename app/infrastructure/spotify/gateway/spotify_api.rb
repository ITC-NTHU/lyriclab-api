# frozen_string_literal: true

require 'http'

module LyricLab
  # Library for Spotify Web API
  module Spotify
    # Spotify API client
    class Api
      def initialize(client_id, client_secret)
        @sp_client_id = client_id
        @sp_clientsecret = client_secret
      end

      def track_data(search_string, n)
        raise ArgumentError, 'Maximum number of tracks must be in Range 0-50' if n <= 0 or n > 50
        Request.new(@sp_client_id, @sp_clientsecret).track(search_string, n).parse
      end

      # Sends out HTTP requests to Spotify
      class Request
        API_TOKEN_URL = 'https://accounts.spotify.com/api/token'
        API_SEARCH_URL = 'https://api.spotify.com/v1/search'
        API_TRACK_URL = 'https://api.spotify.com/v1/tracks/'
        API_RENEW_BEARER_HEADER = {
          'Content-Type' => 'application/x-www-form-urlencoded'
        }.freeze

        def initialize(client_id, client_secret)
          @sp_client_id = client_id
          @sp_clientsecret = client_secret
          @sp_bearertoken, @sp_bearertoken_expires = renew_bearer_token
          # bearer token expires after 1h
        end

        def track(search_string, n)
          get("#{API_SEARCH_URL}?q=#{search_string}&type=track&market=TW&limit=#{n}")
        end

        def get(url)
          check_bearer_token
          http_response = HTTP.headers(
            'Authorization' => "Bearer #{@sp_bearertoken}"
          ).get(url)

          Response.new(http_response).tap do |response|
            raise(response.error) unless response.successful?
          end
        end

        private

        def renew_bearer_token
          body = {
            grant_type: 'client_credentials',
            client_id: @sp_client_id,
            client_secret: @sp_clientsecret
          }
          http_response = HTTP.headers(API_RENEW_BEARER_HEADER).post(API_TOKEN_URL, form: body)
          result = Response.new(http_response).tap do |response|
            raise(response.error) unless response.successful?
          end
          [result.parse['access_token'], (Time.now + 3600)]
        end

        def check_bearer_token
          return unless @sp_bearertoken_expires < Time.now

          @sp_bearertoken, @sp_bearertoken_expires = renew_bearer_token
        end
      end

      # Decorates HTTP responses from Spotify with success/error reporting
      class Response < SimpleDelegator
        BadRequest = Class.new(StandardError)
        Unauthorized = Class.new(StandardError)
        NotFound = Class.new(StandardError)

        HTTP_ERROR = {
          400 => BadRequest,
          401 => Unauthorized,
          404 => NotFound
        }.freeze

        def successful?
          HTTP_ERROR.keys.none?(code)
        end

        def error
          HTTP_ERROR[code]
        end
      end
    end
  end
end
