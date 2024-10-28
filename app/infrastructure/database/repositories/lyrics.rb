# frozen_string_literal: true

module LyricLab
  module Repository
    # Repository for Lyrics
    class Lyrics
      def self.find_id(id)
        rebuild_entity Database::LyricsOrm.first(id:)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Lyrics.new(
          id: db_record.id,
          text: db_record.text
          is_instrumental: db_record.is_instrumental
          is_mandarin: db_record.is_mandarin
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_lyrics|
          Lyrics.rebuild_entity(db_lyrics)
        end
      end

      def self.find_or_create(entity)
        Database::LyricsOrm.find_or_create(entity.to_attr_hash)
      end
    end
  end
end
