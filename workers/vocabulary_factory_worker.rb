# frozen_string_literal: true

require_relative '../require_app'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to clone repos in parallel
class VocabularyFactoryWorker
  # Environment variables setup
  Figaro.application = Figaro::Application.new(
    environment: ENV['RACK_ENV'] || 'development',
    path: File.expand_path('config/secrets.yml')
  )
  Figaro.load
  def self.config = Figaro.env

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.VOCABULARY_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    # this probably doesn't work like this
    request_data = JSON.parse(request)
    raise 'Vocabulary already exists' unless request_data['vocabulary']['unique_words'].empty?

    data_struct = OpenStruct.new(request_data['vocabulary'])
    vocabulary = LyricLab::Repository::Vocabularies.rebuild_entity(data_struct)
    vocabulary.generate_content
    puts "Vocabulary generated: #{vocabulary.inspect}"
    LyricLab::Repository::Vocabularies.update(vocabulary)
  rescue StandardError => e
    puts "Error: #{e}"
    puts e.backtrace[0...5].join("\n")
    puts "Input Data was #{data_struct}"
  end
end
