# frozen_string_literal: true

module LyricLab
  module Repository
    # Repository for Lyrics
    class Words
      def self.find_id(id)
        rebuild_entity Database::WordOrm.first(id:)
      end

      def self.find_by_characters(characters)
        rebuild_entity Database::WordOrm.first(characters: characters)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Word.new(
          id: db_record.id,
          characters: db_record.characters,
          pinyin: db_record.pinyin,
          translation: db_record.translation,
          word_type: db_record.word_type,
          example_sentence: db_record.example_sentence
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_word|
          Words.rebuild_entity(db_word)
        end
      end

      def self.rebuild_entity_from_hash(word_hash)
        return nil unless word_hash

        Entity::Word.new(
          id: word_hash[:id],
          characters: word_hash[:characters],
          pinyin: word_hash[:pinyin],
          translation: word_hash[:translation],
          word_type: word_hash[:word_type],
          example_sentence: word_hash[:example_sentence]
        )
      end

      def self.rebuild_many_from_hash(word_hash_list)
        word_hash_list.map do |word_hash|
          Words.rebuild_entity_from_hash(word_hash)
        end
      end

      def self.find_or_create(entity)
        Database::WordOrm.find_or_create(entity.to_attr_hash)
      end
    end
  end
end
