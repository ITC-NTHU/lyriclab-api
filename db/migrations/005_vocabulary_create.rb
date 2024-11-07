# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  up do
    create_table(:vocabularies) do
      primary_key :id

      String :language_level

      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:vocabularies)
  end
end
