# frozen_string_literal: true

require 'google/cloud/translate/v2'

module LyricLab
  module Google
    # library for google translate API
    class Api
      def initialize(client_key)
        @client = ::Google::Cloud::Translate::V2.new(key: client_key)
      end

      def detect_language(input)
        @client.detect(input).language
      rescue ::Google::Cloud::Error => e
        handle_error(e)
      end

      private

      class BadRequestError < StandardError; end
      class UnauthorizedError < StandardError; end
      class NotFoundError < StandardError; end
      class InternalServerError < StandardError; end

      # Custom method to handle Google API errors and raise appropriate exceptions
      def handle_error(error) # rubocop:disable Metrics/MethodLength
        case error.status_code
        when 400
          raise BadRequestError, "Bad Request: #{error.message}"
        when 401
          raise UnauthorizedError, "Unauthorized: #{error.message}"
        when 404
          raise NotFoundError, "Not Found: #{error.message}"
        when 500
          raise InternalServerError, "Internal Server Error: #{error.message}"
        else
          # Raise a generic error for unexpected status codes
          raise StandardError, "Google API Error (#{error.status_code}): #{error.message}"
        end
      end
    end
  end
end
