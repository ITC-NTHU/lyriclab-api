# frozen_string_literal: true

require 'sequel'

module LyricLab
  module Database
    # Object Relational Mapper for Project Entities
    class SongOrm < Sequel::Model(:songs)
      one_to_one :lyrics,
                 class: :'LyricLab::Database::LyricsOrm',
                 key: :lyrics_id

      plugin :timestamps, update_on_create: true
    end
  end
end
