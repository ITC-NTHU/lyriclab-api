# frozen_string_literal: true

require 'rack' # for Rack::MethodOverride
require 'roda'

module LyricLab
  # Web App
  class App < Roda # rubocop:disable Metrics/ClassLength
    plugin :halt
    plugin :caching

    route do |routing| # rubocop:disable Metrics/BlockLength
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

      routing.on 'api/v1' do # rubocop:disable Metrics/BlockLength
        routing.on 'recommendations' do
          # GET /api/v1/recommendations/targeted?language_difficulty={language_difficulty}
          routing.on 'targeted' do
            routing.get do
              # request_body = routing.body.read
              # json_data = JSON.parse(request_body)
              language_difficulty = routing.params['language_difficulty']
              # TODO: @Irina write a requests service thingy to verifiy the language_difficulty used
              # So it stays in the desired range of 0 to 7 just like we did with the search query
              recommendations = Service::ListTargetedRecommendations.new.call(language_difficulty)

              if recommendations.failure?
                failed = Representer::HttpResponse.new(recommendations.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(recommendations.value!)
              response.status = http_response.http_status_code
              Representer::RecommendationsList.new(recommendations.value!.message).to_json
            end
          end

          routing.is do
            # return recommendations as array of objects
            # GET /api/v1/recommendations
            routing.get do
              result = Service::ListRecommendations.new.call

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end
              # puts("Recommendations: #{result.value!.message}")
              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::RecommendationsList.new(result.value!.message).to_json
            end
          end
        end

        routing.on 'search_results' do # rubocop:disable Metrics/BlockLength
          routing.on String do |ids|
            routing.get do
              ids = ids.split('-')
              result = Service::LoadSongs.new.call(ids)

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

          routing.is do
            # return search results in form of song objects
            # GET /api/v1/search_results?search_query={search_query}
            routing.get do
              # App.configure :production do
              #   response.cache_control public: true, max_age: 300
              # end
              response.cache_control public: true, max_age: 120
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
          routing.on String do |origin_id|
            # record recommendation update
            # POST /api/v1/songs/{origin_id}
            routing.post do
              result = Service::RecordRecommendation.new.call(origin_id)
              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Recommendation.new(result.value!.message).to_json
            end

            # return metadata for single song object
            # GET /api/v1/songs/{origin_id}
            routing.get do
              result = Service::LoadSong.new.call(origin_id)

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
          routing.on String do |origin_id|
            # return vocabularies
            # GET /api/v1/vocabularies/{origin_id}
            routing.get do
              # App.configure :production do
              #   response.cache_control public: true, max_age: 300
              # end

              request_id = [request.env, request.path, Time.now.to_f].hash

              result = Service::GenVocabulary.new.call(
                origin_id: origin_id,
                request_id: request_id
              )

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              # result = Service::LoadVocabulary.new.call(origin_id)
              # puts 'Vocabulary was trying to load'
              # if result.failure?
              #   failed = Representer::HttpResponse.new(result.failure)
              #   routing.halt failed.http_status_code, failed.to_json
              # end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              puts Representer::Song.new(result.value!.message).to_json

              Representer::Song.new(
                result.value!.message
              ).to_json
            rescue StandardError => e
              App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
            end
          end
        end
      end
    end
  end
end
