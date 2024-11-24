# frozen_string_literal: true

# if we are returning arrays or collections, we will
# need a Response Object for representation

module LyricLab
  module Response
    # List of projects
    SongsList = Struct.new(:songs)
  end
end
