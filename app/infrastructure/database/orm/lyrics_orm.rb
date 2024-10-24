# frozen_string_literal: true

require 'sequel'

module LyricLab
  module Database
    # Object Relational Mapper for Project Entities
    class LyricsOrm < Sequel::Model(:lyrics)
      one_to_many :song,
                  class: :'LyricLab::Database::SongOrm',
                  key: :lyrics_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(lyrics_info)
        first(text: lyrics_info[:text]) || create(lyrics_info)
      end
    end
  end
end
