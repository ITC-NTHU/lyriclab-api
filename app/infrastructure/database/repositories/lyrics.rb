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

        #convert db string representation of unique words to array
        if !db_record.unique_words.nil?
          db_record.unique_words = db_record.unique_words.split(' ')
        end

        Entity::Lyrics.new(
          id: db_record.id,
          text: db_record.text,
          is_mandarin: db_record.is_mandarin,
          unique_words: db_record.unique_words,
          is_instrumental: nil
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
