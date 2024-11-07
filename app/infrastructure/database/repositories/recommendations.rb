# frozen_string_literal: true

module LyricLab
  module Repository
    # Repository for Recommendations
    class Recommendations
      def self.all
        Database::RecommendationOrm.all.map { |db_recommendation| rebuild_entity(db_recommendation) }
      end

      def self.find_id(id)
        rebuild_entity Database::RecommendationOrm.first(id:)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Recommendation.new(db_record.title, db_record.artist_name_string, db_record.search_cnt,
                                   db_record.spotify_id)
      end

      def self.top_searched_songs
        db_recommendations = Database::RecommendationOrm.order(Sequel.desc(:search_cnt)).limit(5)
        db_recommendations.map { |db_recommendation| rebuild_entity(db_recommendation) }
      end

      def self.find_spotify_id(spotify_id)
        db_record = Database::RecommendationOrm.first(spotify_id:)
        rebuild_entity(db_record)
      end

      def self.increment_cnt(spotify_id)
        Database::RecommendationOrm.where(spotify_id:).update(search_cnt: Sequel[:search_cnt] + 1)
        db_record = Database::RecommendationOrm.where(spotify_id:).first
        rebuild_entity(db_record)
      end

      def self.create(entity)
        if find_spotify_id(entity.spotify_id)
          increment_cnt(entity.spotify_id)
        else
          db_recommendation = PersistRecommendation.new(entity).create_recommendation
          rebuild_entity(db_recommendation)
        end
      end

      # Persist a recommendation to the database
      class PersistRecommendation
        def initialize(entity)
          @entity = entity
        end

        def create_recommendation
          Database::RecommendationOrm.create(@entity.to_attr_hash)
        end
      end
    end
  end
end
