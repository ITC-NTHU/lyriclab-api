# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:words) do
      primary_key :id

      String     :characters, null: false
      String     :translation, null: false
      String     :pinyin, null: false
      String     :word_type

      String     :easy_sentence, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
