# frozen_string_literal: true

require 'roda'
require 'yaml'
require 'figaro'
require 'sequel'

module LyricLab
  # Configuration for the App
  class App < Roda
    plugin :environments

    configure do
      # Environment variables setup
      Figaro.application = Figaro::Application.new(
        environment:,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config = Figaro.env

      configure :development, :test do
        ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
      end

      # Database Setup
      @db = Sequel.connect(ENV.fetch('DATABASE_URL'))
      def self.db = @db # rubocop:disable Style/TrivialAccessors

      # Word List Setup (load into memory)
      # [novice1, novice2, level1, level2, level3, level4, level5]
      # word_list[[characters, pinyin, word_type], ...]
      @word_list = YAML.load_file('files/mandarin_word_list.yml')
      # puts "length of word list: #{@word_list.length}"
      # puts "Word List: #{@word_list[0]}"
      @merged_word_list = @word_list.values().flatten(1)
      # puts "Merged Word List: #{@merged_word_list[0]}"
      # puts "Merged Word List: #{@merged_word_list}"
      # puts "length of merged word list: #{@merged_word_list.length}"
      # [beginner, novice1, novice2, level1, level2, level3, level4, level5]
      @list_indexes = [0]
      current_index = 0

      @word_list.values().each do |list|
        current_index += list.size
        @list_indexes << current_index
      end

      @merged_word_list = @merged_word_list.map! { |word| word[0]} # rubocop:disable Style/TrivialAccessors
      def self.merged_word_list = @merged_word_list
      # puts "Word List: #{self.merged_word_list}"
      def self.list_indexes = @list_indexes # rubocop:disable Style/TrivialAccessors
      def self.word_list = @word_list # rubocop:disable Style/TrivialAccessors

    end
  end
end
