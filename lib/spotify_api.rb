# frozen_string_literal: true

require 'http'
require_relative 'song'

module GoodName
  # Library for Spotify Web API

  class SpotifyApi
    # Spotify API client
    API_TOKEN_URL = 'https://accounts.spotify.com/api/token'
    API_SEARCH_URL = 'https://api.spotify.com/v1/search'
    API_TRACK_URL = 'https://api.spotify.com/v1/tracks/'

    def initialize(client_id, token)
      @sp_clientsecret = token
      # expires after 1h
      @sp_client_id = client_id
      @sp_bearertoken, @sp_bearertoken_expires = renew_bearer_token()
    end

    def song(search_string)
      song_response = Request.new(@sp_client_id, @sp_bearertoken).track(search_string).parse
      Song.new(song_response, self)
    end

    # Sends out HTTP requests to Spotify
    class Request
      def initialize(client_id, token)
        @sp_clientsecret = token
        # expires after 1h
        @sp_client_id = client_id
        @sp_bearertoken, @sp_bearertoken_expires = renew_bearer_token()
      end

      def track(search_string)
        get("#{API_SEARCH_URL}?q=#{search_string}&type=track&market=TW&limit=1")

      end

      def get(url)
        is_bearer_token_alive?()
        http_response = HTTP.headers(
          'Authorization' => "Bearer #{@sp_bearertoken}"
        ).get(url)

        Response.new(http_response).tap do |response|
          raise(response.error) unless response.successful?
        end
      end



      private

      def renew_bearer_token()
        headers = {
          'Content-Type' => 'application/x-www-form-urlencoded'
        }
        body = {
          grant_type: 'client_credentials',
          client_id: @sp_client_id,
          client_secret: @sp_clientsecret
        }
        http_response = HTTP.headers(headers).post(url, form: body)
        Response.new(http_response).tap do |response|
          raise(response.error) unless response.successful?
        end

        # unless successful?(result) then raise HTTP_ERROR[result.code] end
        return result.parse['access_token'], (Time.now + 3600)
      end

      def is_bearer_token_alive?()
        if @sp_bearertoken_expires < Time.now
          @sp_bearertoken, @sp_bearertoken_expires = renew_bearer_token()
        end
      end

    end

    # Decorates HTTP responses from Spotify with success/error reporting
    class Response < SimpleDelegator
      Unauthorized = Class.new(StandardError)
      NotFound = Class.new(StandardError)

      HTTP_ERROR = {
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