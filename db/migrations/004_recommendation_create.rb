# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:recommendations) do
      primary_key :id
      foreign_key :song_id, :songs, null: false

      String     :title, null: false
      String     :artist, null: false
      String     :search_cnt, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
