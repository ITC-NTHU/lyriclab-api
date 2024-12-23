# frozen_string_literal: true

module LyricLab
  module Repository
    # Repository for Lyrics
    class Vocabularies
      def self.find_id(id)
        rebuild_entity Database::VocabularyOrm.first(id:)
      end

      def self.rebuild_entity(db_record) # rubocop:disable Metrics/MethodLength
        return nil unless db_record

        unique_words = if db_record.unique_words.nil?
                         []
                       else
                         db_record.unique_words.map do |word|
                           Words.rebuild_entity(word)
                         end
                       end

        Entity::Vocabulary.new(
          id: db_record.id,
          unique_words:,
          sep_text: db_record.sep_text,
          raw_text: db_record.raw_text,
          language_difficulty: db_record.language_difficulty,
          vocabulary_factory: OpenAI::VocabularyFactory.new
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

      def self.update(entity) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        db_vocabulary = find_db_vocabulary(entity.id)
        update_vocabulary_attributes(db_vocabulary, entity)

        db_vocabulary_words = Words.rebuild_many(db_vocabulary.unique_words).map(&:characters)

        entity.unique_words.each do |word|
          if db_vocabulary_words.include?(word.characters)
            Words.update(word)
          elsif !db_vocabulary.unique_words.map(&:characters).include?(word.characters)
            db_vocabulary.add_unique_word(Words.find_or_create(word))
          end
        end
      rescue StandardError => e
        App.logger.error(e.message.to_s)
        nil
      end

      def self.find_db_vocabulary(vocabulary_id)
        db_vocabulary = Database::VocabularyOrm.first(id: vocabulary_id)
        raise "Vocabulary with id #{vocabulary_id} not found" if db_vocabulary.nil?

        db_vocabulary
      end

      def self.update_vocabulary_attributes(db_vocabulary, entity)
        db_vocabulary.update(entity.to_attr_hash)
      end

      def self.find_or_create_song_id(song_id, entity)
        Database::VocabularyOrm.find_or_create_song_id(song_id, entity.to_attr_hash)
      end

      # Helper class to persist vocabularies and its unique_words to database
      class PersistVocabulary
        def initialize(entity)
          @entity = entity
        end

        def create_vocabulary
          # puts "create vocabulary: raw text is nil? #{@entity.raw_text.nil?}"
          Database::VocabularyOrm.create(@entity.to_attr_hash)
        end

        def call
          if @entity.unique_words.empty?
            create_vocabulary
          else
            create_vocabulary.tap do |db_vocabulary|
              @entity.unique_words.each do |word|
                db_vocabulary.add_unique_word(Words.find_or_create(word))
              end
            end
          end
        end
      end
    end
  end
end
