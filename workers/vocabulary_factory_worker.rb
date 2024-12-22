# frozen_string_literal: true

require_relative '../require_app'
require_relative 'gen_voc_monitor'
require_relative 'job_reporter'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to clone repos in parallel
module GenerateVocabulary
  # Worker to extract word metadata
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

    # if config.RACK_ENV == 'test'
    #   require_relative '../spec/helpers/spec_helper'
    #   require_relative '../spec/helpers/vcr_helper'
    #   puts 'Running in test mode'
    #   VcrHelper.setup_vcr
    # end

    include Shoryuken::Worker
    shoryuken_options queue: config.VOCABULARY_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request) # rubocop:disable Metrics/MethodLength
      # before

      job = JobReporter.new(request, VocabularyFactoryWorker.config)

      job.report(GenerateMonitor.starting_percent)

      vocabulary = LyricLab::Repository::Vocabularies.rebuild_entity(job.song.vocabulary)
      vocabulary.generate_content do |progress|
        job.report GenerateMonitor.progress(progress)
      end

      # after

      LyricLab::Repository::Vocabularies.update(vocabulary)

      # Keep sending finished status to any latecoming subscribers
      job.report_each_second(7) { GenerateMonitor.finished_percent }
    rescue StandardError => e
      after
      puts "Error: #{e}"
    end

    # def before
    #  VcrHelper.configure_vcr_for_gpt if VocabularyFactoryWorker.config.RACK_ENV == 'test'
    # end

    # def after
    #  VcrHelper.eject_vcr if VocabularyFactoryWorker.config.RACK_ENV == 'test'
    # end

    def check_eligibility(request_data)
      db_vocab = LyricLab::Database::VocabularyOrm.first(id: request_data['vocabulary']['id'])

      vocabulary_exists = !db_vocab.nil?
      raise 'Vocabulary does not exsist in db' unless vocabulary_exists
      return if request_data['vocabulary']['unique_words'].empty? && db_vocab.unique_words.empty?

      raise 'Vocabulary already exists'
    end
  end
end
