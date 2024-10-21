# frozen_string_literal: true

# Helper to clean database during test runs
module DatabaseHelper
  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    LyricLab::App.db.run('PRAGMA foreign_keys = OFF')
    LyricLab::Database::MemberOrm.map(&:destroy) # TODO
    LyricLab::Database::ProjectOrm.map(&:destroy) # TODO
    LyricLab::App.db.run('PRAGMA foreign_keys = ON')
  end
end
