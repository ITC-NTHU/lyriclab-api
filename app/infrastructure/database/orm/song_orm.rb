# frozen_string_literal: true

require 'sequel'

module LyricLab
  module Database
    # Object Relational Mapper for Project Entities
    class SongOrm < Sequel::Model(:songs)
      many_to_one :lyrics,
                  class: :'LyricLab::Database::LyricsOrm'

      plugin :timestamps, update_on_create: true
      plugin :whitelist_security
    end
  end
end
