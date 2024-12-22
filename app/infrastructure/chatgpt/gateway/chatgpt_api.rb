# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'yaml'
require 'delegate'
require 'http'
require 'openai'

module LyricLab
  module OpenAI
    # Library for OpenAI API
    class API
      def initialize(api_key)
        raise ArgumentError, 'API key cannot be nil' if api_key.nil?
        raise ArgumentError, 'Invalid API key format' unless api_key.start_with?('sk-')

        @api_key = api_key
      end

      def chat_response(messages)
        Request.new(@api_key).chat(messages)
      end

      # Sends out HTTP requests to OpenAI
      class Request
        API_URL = 'https://api.openai.com/v1/chat/completions'

        def initialize(api_key)
          @api_key = api_key
          # puts "Loaded API Key: #{@api_key}"
        end

        def chat(messages)
          puts "Sending messages to GPT: #{messages}"
          post(API_URL, { model: 'gpt-4o-mini', messages: })
        end

        def post(url, payload) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
          headers = {
            'Authorization' => "Bearer #{@api_key}",
            'Content-Type'  => 'application/json',
            'Accept'        => 'application/json'
          }

          http_response = RestClient::Request.execute(
            method: :post,
            url:,
            payload: payload.to_json,
            headers:
          )

          Response.new(http_response).tap do |response|
            raise(response.error, "HTTP #{response.code}: #{response.body}") unless response.successful?
          end.parse
        rescue RestClient::ExceptionWithResponse => e
          App.logger.error("REST client error: #{e.inspect}#{e.response}")
          handle_api_error(e.response)
          nil
        rescue StandardError => e
          App.logger.error("Unexpected error: #{e.message}")
          nil
        end

        private

        def handle_api_error(response)
          error_body = JSON.parse(response.body)
          error_message = begin
            error_body['error']['message']
          rescue StandardError
            App.logger.error('ChatGPT API: Unkown Error')
          end
          App.logger.error("ChatGPT API Error: #{error_message}")
        end
      end

      # Decorates HTTP responses from OpenAI with success/error reporting
      class Response < SimpleDelegator
        BadRequest = Class.new(StandardError)
        Unauthorized = Class.new(StandardError)
        NotFound = Class.new(StandardError)
        # RateLimitExceeded = Class.new(StandardError)

        HTTP_ERROR = {
          '400' => BadRequest,
          '401' => Unauthorized,
          '404' => NotFound
          # '429' => RateLimitExceeded
        }.freeze

        def successful?
          HTTP_ERROR.keys.none?(code)
        end

        def error
          HTTP_ERROR[code]
        end

        def parse
          response_body = JSON.parse(__getobj__.body)
          response_body['choices'][0]['message']['content']
        rescue JSON::ParserError => e
          App.logger.error("Error parsing JSON: #{e.message}")
        end
      end
    end
  end
end
