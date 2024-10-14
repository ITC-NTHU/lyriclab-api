# # frozen_string_literal: true

# require 'http'
# require_relative 'lyrics'

# module LyricLab
#   # library for lrclib API
#   class LrclibApi
#     BASE_URL = 'https://lrclib.net/api/get'

#     def song_lyrics(song_ttl, artist_name)
#       lyrics_data = Request.new(BASE_URL).req(song_ttl, artist_name).parse
#       #raise Response::NotFound, 'Lyrics not found' if lyrics_data.nil? || lyrics_data.empty?
#       Lyrics.new(lyrics_data, self)
#     end

#     # Sends out HTTP requests to API
#     class Request
#       def initialize(resource_root)
#         @resource_root = resource_root
#       end

#       def req(song_ttl, artist_name)
#         call(song_ttl, artist_name)
#       end

#       def call(song_ttl, artist_name)
#         params = {
#           track_name: song_ttl,
#           artist_name: artist_name
#         }

#         http_response = HTTP.get(@resource_root, params: params)

#         Response.new(http_response).tap do |response|
#           raise(response.error) unless response.successful?
#         end
#       end
#     end

#     # Decorates HTTP responses from API with success/error reporting
#     class Response < SimpleDelegator
#       NotFound = Class.new(StandardError)

#       HTTP_ERROR = {
#         404 => NotFound
#       }.freeze

#       def successful?
#         HTTP_ERROR.keys.none?(code)
#       end

#       def error
#         HTTP_ERROR[code]
#       end
#     end
#   end
# end
