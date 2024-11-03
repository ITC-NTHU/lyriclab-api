# frozen_string_literal: true

require_relative 'songs'
require_relative 'lyrics'
require_relative 'vocabularies'
require_relative 'words'
require_relative 'recommendations' 

module LyricLab
  module Repository
    # Finds the right repository for an entity object or class
    class For
      ENTITY_REPOSITORY = {
        Entity::Song => Songs,
        Entity::Lyrics => Lyrics,
        Entity::Vocabulary => Vocabularies,
        Entity::Word => Words,
        Entity::Recommendation => Recommendations
      }.freeze

      def self.klass(entity_klass)
        ENTITY_REPOSITORY[entity_klass]
      end

      def self.entity(entity_object)
        ENTITY_REPOSITORY[entity_object.class]
      end
    end
  end
end
