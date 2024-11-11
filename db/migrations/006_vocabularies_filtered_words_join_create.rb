# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  up do
    create_table(:vocabularies_unique_words) do
      primary_key [:vocabulary_id, :unique_word_id] # rubocop:disable Style/SymbolArray
      foreign_key :vocabulary_id, :vocabularies
      foreign_key :unique_word_id, :words

      index [:vocabulary_id, :unique_word_id] # rubocop:disable Style/SymbolArray
    end
  end

  down do
    drop_table(:vocabularies_unique_words)
  end
end
