# frozen_string_literal: true

# Helper to clean database during test runs
module DatabaseHelper
  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    LyricLab::App.db.run('PRAGMA foreign_keys = OFF')
    LyricLab::Database::SongOrm.map(&:destroy) # TODO: check what has to be destroyed (all ORMs should be destroyed)
    LyricLab::Database::LyricsOrm.map(&:destroy)
    LyricLab::App.db.run('PRAGMA foreign_keys = ON')
  end
end
