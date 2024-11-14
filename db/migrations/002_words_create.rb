# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  up do
    create_table(:words) do
      primary_key :id

      String     :characters, null: false, unique: true
      String     :translation, null: false
      String     :pinyin, null: false
      String     :language_level
      String     :definition
      String     :word_type
      String     :example_sentence

      DateTime :created_at
      DateTime :updated_at
    end

    alter_table(:words) do
      add_constraint(:language_level_constraint,
                     language_level: %w[beginner novice1 novice2 level1 level2 level3 level4 level5])
    end
  end

  down do
    drop_table(:words)
  end
end
