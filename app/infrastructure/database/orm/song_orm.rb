# frozen_string_literal: true

require 'sequel'

module LyricLab
  module Database
    # Object Relational Mapper for Song Entities
    class SongOrm < Sequel::Model(:songs)
      many_to_one :lyrics,
                  class: :'LyricLab::Database::LyricsOrm'

      many_to_one :vocabulary,
                  class: :'LyricLab::Database::VocabularyOrm',
                  key: :vocabulary_id,
                  primary_key: :id,
                  table: :vocabularies

      plugin :timestamps, update_on_create: true
    end
  end
end
