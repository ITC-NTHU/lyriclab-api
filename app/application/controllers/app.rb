# frozen_string_literal: true

require 'rack' # for Rack::MethodOverride
require 'roda'

module LyricLab
  # Web App
  class App < Roda
    # plugin :sessions, secret: config.SESSION_SECRET
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)

    # rubocop:disable Metrics/BlockLength
    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "LyricLab API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message:)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        routing.on 'recommendations' do
          # return recommendations as array of objects
          # GET /api/v1/recommendations
          routing.get do
            result = Service::ListRecommendations.new.call

            if result.failure?
              failed = Representer::HttpResponse.new(result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end

            http_response = Representer::HttpResponse.new(result.value!)
            response.status = http_response.http_status_code
            Representer::RecommendationsList.new(result.value!.message).to_json
          end
        end

        routing.on 'search_results' do
          routing.is do
            # return search results in form of song objects
            # GET /api/v1/search_results?search_query={search_query}
            routing.get do
              search_query = Request::EncodedSearchQuery.new(routing.params)
              result = Service::LoadSearchResults.new.call(search_query)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::SearchResults.new(
                result.value!.message
              ).to_json
            end
          end
        end

        routing.on 'songs' do
          routing.on String do |spotify_id|
            # update recommendations
            # PUT /api/v1/songs/{spotify_id}
            routing.put do
              result = Service::Record.new.call(spotify_id)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Recommendation.new(result.value!.message).to_json
            end

            # return metadata for single song object
            # GET /api/v1/songs/{spotify_id}
            routing.get do
              result = Service::LoadSong.new.call(spotify_id)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::Song.new(
                result.value!.message
              ).to_json
            end
          end
        end

        routing.on 'vocabularies' do
          routing.on String do |spotify_id|
            # return vocabularies
            # GET /api/v1/vocabularies/{spotify_id}
            routing.get do
              result = Service::LoadVocabulary.new.call(spotify_id)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::Song.new(
                result.value!.message
              ).to_json
            end
          end
        end
      end
    end
  end
end
