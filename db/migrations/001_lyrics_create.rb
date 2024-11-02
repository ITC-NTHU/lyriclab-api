# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:lyrics) do
      primary_key :id

      String :text
      Bool :is_mandarin
      Bool :is_instrumental
      String :unique_words

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
