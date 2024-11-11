# frozen_string_literal: true

require 'sequel'

module LyricLab
  module Database
    # Object Relational Mapper for Project Entities
    class WordOrm < Sequel::Model(:words)
      many_to_many :vocabularies,
                   class: :'LyricLab::Database::VocabularyOrm',
                   join_table: :vocabularies_filtered_words,
                   left_key: :filtered_word_id, right_key: :vocabulary_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(word_info)
        first(characters: word_info[:characters]) || create(word_info)
      end
    end
  end
end
