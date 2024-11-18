# frozen_string_literal: true

require 'dry/monads'

module LyricLab
  module Service
    # Retrieves array of all listed project entities
    class LoadSearchResults
      include Dry::Monads::Result::Mixin

      def call(ids)
        search_results = ids.map do |id|
          Repository::For.klass(Entity::Song).find_spotify_id(id)
        end
        Success(search_results)
      rescue StandardError
        Failure('could not access database')
      end
    end
  end
end
