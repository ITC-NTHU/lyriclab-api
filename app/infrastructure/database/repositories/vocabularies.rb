# frozen_string_literal: true

module LyricLab
  module Repository
    # Repository for Lyrics
    class Vocabularies
      def self.find_id(id)
        rebuild_entity Database::VocabularyOrm.first(id:)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record
        filtered_words = db_record.filtered_words.map do |word|
          Words.rebuild_entity(word)
        end
        Entity::Vocabulary.new(
          id: db_record.id,
          language_level: db_record.language_level,
          filtered_words: filtered_words
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_vocabularies|
          Vocabularies.rebuild_entity(db_vocabularies)
        end
      end

      def self.create(entity)
        db_vocabulary = PersistVocabulary.new(entity).call
        rebuild_entity(db_vocabulary)
      end

      def self.find_or_create(entity)
        Database::VocabularyOrm.first(id: entity.to_attr_hash[:id]) || PersistVocabulary.new(entity).call
        # old: Database::VocabularyOrm.find_or_create(entity.to_attr_hash)
      end

      def self.find_or_create_song_id(song_id, entity)
        Database::VocabularyOrm.find_or_create_song_id(song_id, entity.to_attr_hash)
      end

      # Helper class to persist vocabularies and its filtered_words to database
      class PersistVocabulary
        def initialize(entity)
          @entity = entity
        end

        def create_vocabulary
          # puts "create vocabulary: #{@entity.to_attr_hash}"
          Database::VocabularyOrm.create(@entity.to_attr_hash)
        end

        def call
          unless @entity.filtered_words.nil?
            create_vocabulary.tap do |db_vocabulary|
              @entity.filtered_words.each do |word|
                db_vocabulary.add_filtered_word(Words.find_or_create(word))
              end
            end
          else
            create_vocabulary
          end
        end
      end

    end
  end
end
