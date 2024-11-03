# frozen_string_literal: true

require 'sequel'

module LyricLab
  module Database
    # Object Relational Mapper for Recommendation Entities
    class RecommendationOrm < Sequel::Model(:recommendations)
      one_to_many :song,
                  class: :'LyricLab::Database::SongOrm',
                  key: :recommendation_id

      plugin :timestamps, update_on_create: true
      plugin :whitelist_security
    end
  end
end