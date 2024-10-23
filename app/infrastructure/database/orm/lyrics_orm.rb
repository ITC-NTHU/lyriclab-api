# frozen_string_literal: true

require 'sequel'

module LyricLab
  module Database
    # Object Relational Mapper for Project Entities
    class LyricsOrm < Sequel::Model(:songs)
      one_to_one :song,
                 class: :'LyricLab::Database::SongOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
