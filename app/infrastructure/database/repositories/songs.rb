# frozen_string_literal: true

require_relative 'members'

module LyricLab
  module Repository
    # Repository for Project Entities
    class Songs
      def self.all
        Database::SongOrm.all.map { |db_song| rebuild_entity(db_song) }
      end

      def self.find_from_title_artist(title, artist_name)
        db_song = Database::SongOrm
                  .where(title:, artist_name:)
                  .first
        rebuild_entity(db_song)
      end

      def self.find(entity)
        find_origin_id(entity.origin_id)
      end

      def self.find_id(id)
        db_record = Database::SongOrm.first(id:)
        rebuild_entity(db_record)
      end

      def self.find_spotify_id(spotify_id)
        db_record = Database::SongOrm.first(spotify_id:)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        raise 'Song already exists' if find(entity)

        db_song = PersistSong.new(entity).call
        rebuild_entity(db_song)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Song.new(
          db_record.to_hash.merge(
            lyrics: Lyrics.rebuild_entity(db_record.lyrics)
          )
        )
      end

      # Helper class to persist project and its members to database
      class PersistSong
        def initialize(entity)
          @entity = entity
        end

        def create_project
          Database::SongOrm.create(@entity.to_attr_hash)
        end

        def call
          lyrics = Lyrics.db_find_or_create(@entity.lyrics)

          create_song.tap do |db_song|
            db_song.update(lyrics:)
          end
        end
      end
    end
  end
end
