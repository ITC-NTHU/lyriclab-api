# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:vocabularies_filtered_words) do
      primary_key [:vocabulary_id, :filtered_word_id] # rubocop:disable Style/SymbolArray
      foreign_key :vocabulary_id, :vocabularies
      foreign_key :filtered_word_id, :words

      index [:vocabulary_id, :filtered_word_id] # rubocop:disable Style/SymbolArray
    end
  end
end
