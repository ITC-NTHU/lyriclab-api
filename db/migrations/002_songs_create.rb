# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:songs) do
      primary_key :id
      foreign_key :lyrics_id, :lyrics

      String     :title, null: false
      String     :spotify_id, null: false
      Integer    :popularity, null: false
      String     :preview_url
      String     :album_name, null: false
      String     :artist_name_string, null: false
      String     :cover_image_url_big
      String     :cover_image_url_medium
      String     :cover_image_url_small
      Boolean    :explicit, null: false, default: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
