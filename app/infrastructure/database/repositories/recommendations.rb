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

        record = {
          title: db_record.title,
          artist_name_string: db_record.artist_name_string,
          search_cnt: db_record.search_cnt,
          origin_id: db_record.origin_id,
          language_difficulty: db_record.language_difficulty,
          cover_image_url_small: db_record.cover_image_url_small
        }
        # puts "rebuilt recommendations language_difficulty: #{record[:language_difficulty]}"
        Entity::Recommendation.new(record)
      end

      def self.top_searched_songs
        db_recommendations = Database::RecommendationOrm.order(Sequel.desc(:search_cnt)).limit(5)
        db_recommendations.map { |db_recommendation| rebuild_entity(db_recommendation) }
      end

      def self.top_songs_for_difficulty(language_difficulty)
        range = language_difficulty.to_f - 0.1..language_difficulty.to_f + 0.9
        db_recommendations = Database::RecommendationOrm.where(language_difficulty: range)
          .order(Sequel.desc(:search_cnt)).limit(5)
        db_recommendations.map { |db_recommendation| rebuild_entity(db_recommendation) }
      end

      def self.find_origin_id(origin_id)
        db_record = Database::RecommendationOrm.first(origin_id:)
        rebuild_entity(db_record)
      end

      def self.increment_cnt(origin_id)
        Database::RecommendationOrm.where(origin_id:).update(search_cnt: Sequel[:search_cnt] + 1)
        db_record = Database::RecommendationOrm.where(origin_id:).first
        rebuild_entity(db_record)
      end

      def self.create_or_increment_count(entity)
        if find_origin_id(entity.origin_id)
          puts 'Incrementing search count'
          increment_cnt(entity.origin_id)
        else
          # puts 'Creating new recommendation'
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
          # puts "Persisting recommendation raw: #{@entity.language_difficulty}"
          # puts "Persisting recommendation with language_difficulty: #{@entity.to_attr_hash[:language_difficulty]}"
          Database::RecommendationOrm.create(@entity.to_attr_hash)
        end
      end
    end
  end
end
