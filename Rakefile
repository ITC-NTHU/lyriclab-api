# frozen_string_literal: true

require 'rake/testtask'
require_relative 'require_app'

task :default do
  puts `rake -T`
end

desc 'Run unit and integration tests'
Rake::TestTask.new(:spec) do |t|
  puts 'Make sure worker is running in separate process'
  t.pattern = 'spec/tests/**/*_spec.rb'
  t.warning = false
end

desc 'Keep rerunning unit/integration tests upon changes'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*' --ignore 'repostore/*'"
end

desc 'Run the webserver and application and restart if code changes'
task :rerun do
  sh "rerun -c --ignore 'coverage/*' --ignore 'repostore/*' -- bundle exec puma"
end

namespace :run do
  desc 'Run API in dev mode'
  task :default do
    sh 'rerun -c "bundle exec puma -p 9090"'
  end
  desc 'Run API in test mode'
  task :test do
    sh 'RACK_ENV=test bundle exec puma -p 9090'
  end
end

namespace :db do
  desc 'Configure database'
  task :config do
    require 'sequel'
    require_relative 'config/environment' # load config info
    require_relative 'spec/helpers/database_helper'

    def app = LyricLab::App # rubocop:disable Rake/MethodDefinitionInTask
  end

  desc 'Run migrations'
  task :migrate => :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.db, 'db/migrations')
  end

  desc 'Wipe records from all tables'
  task :wipe => :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    require_app(%w[domain infrastructure])
    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task :drop => :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    FileUtils.rm(app.config.DB_FILENAME)
    puts "Deleted #{app.config.DB_FILENAME}"
  end
end

namespace :worker do
  namespace :run do
    desc 'Run the background cloning worker in development mode'
    task :dev => :config do
      sh(
        'RACK_ENV=development bundle exec shoryuken ' \
        '-r ./workers/vocabulary_factory_worker.rb ' \
        '-C ./workers/shoryuken_dev.yml'
      )
    end

    desc 'Run the background cloning worker in testing mode'
    task :test => :config do
      sh 'RACK_ENV=test bundle exec shoryuken -r ./workers/vocabulary_factory_worker.rb -C ./workers/shoryuken_test.yml'
    end

    desc 'Run the background cloning worker in testing mode for Github Actions'
    task :gh_test => :config do
      sh(
        'RACK_ENV=test bundle exec shoryuken ' \
        '-r ./workers/vocabulary_factory_worker.rb ' \
        '-C ./workers/shoryuken_gh_test.yml'
      )
    end

    desc 'Run the background cloning worker in production mode'
    task :production => :config do
      sh(
        'RACK_ENV=production bundle exec shoryuken ' \
        '-r ./workers/vocabulary_factory_worker.rb ' \
        '-C ./workers/shoryuken.yml'
      )
    end
  end
end

desc 'Run application console'
task :console do
  sh 'pry -r ./load_all'
end

namespace :vcr do
  desc 'delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :quality do
  only_app = 'config/ app/'

  desc 'run all static-analysis quality checks'
  task all: %i[rubocop reek flog]

  desc 'code style linter'
  task :rubocop do
    sh 'rubocop $(find . -name \'*.rb\')'
  end

  desc 'code smell detector'
  task :reek do
    sh "reek #{only_app}"
  end

  desc 'complexity analysis'
  task :flog do
    sh "flog -m#{only_app}"
  end
end

namespace :cache do
  task :config do # rubocop:disable Rake/Desc
    require_relative 'config/environment' # load config info
    require_relative 'app/infrastructure/cache/redis_cache'
    @api = LyricLab::App
  end

  desc 'Directory listing of local dev cache'
  namespace :list do
    desc 'Lists development cache'
    task :dev do
      puts 'Lists development cache'
      list = `ls _cache/rack/meta`
      puts 'No local cache found' if list.empty?
      puts list
    end

    desc 'Lists production cache'
    task :production => :config do
      puts 'Finding production cache'
      keys = LyricLab::Cache::Client.new(@api.config).keys
      puts 'No keys found' if keys.none?
      keys.each { |key| puts "Key: #{key}" }
    end
  end

  namespace :wipe do
    desc 'Delete development cache'
    task :dev do
      puts 'Deleting development cache'
      sh 'rm -rf _cache/*'
    end

    desc 'Delete production cache'
    task :production => :config do
      print 'Are you sure you wish to wipe the production cache? (y/n) '
      if $stdin.gets.chomp.downcase == 'y'
        puts 'Deleting production cache'
        wiped = LyricLab::Cache::Client.new(@api.config).wipe
        wiped.each { |key| puts "Wiped: #{key}" }
      end
    end
  end
end

namespace :queues do
  task :config do # rubocop:disable Rake/Desc
    require 'aws-sdk-sqs'
    require_relative 'config/environment' # load config info
    @api = LyricLab::App
    @sqs = Aws::SQS::Client.new(
      access_key_id: @api.config.AWS_ACCESS_KEY_ID,
      secret_access_key: @api.config.AWS_SECRET_ACCESS_KEY,
      region: @api.config.AWS_REGION
    )
    @q_name = @api.config.VOCABULARY_QUEUE
    @q_url = @sqs.get_queue_url(queue_name: @q_name).queue_url

    puts "Environment: #{@api.environment}"
  end

  desc 'Create SQS queue for worker'
  task :create => :config do
    @sqs.create_queue(queue_name: @q_name)

    puts 'Queue created:'
    puts "  Name: #{@q_name}"
    puts "  Region: #{@api.config.AWS_REGION}"
    puts "  URL: #{@q_url}"
  rescue StandardError => e
    puts "Error creating queue: #{e}"
  end

  desc 'Report status of queue for worker'
  task :status => :config do
    puts 'Queue info:'
    puts "  Name: #{@q_name}"
    puts "  Region: #{@api.config.AWS_REGION}"
    puts "  URL: #{@q_url}"
  rescue StandardError => e
    puts "Error finding queue: #{e}"
  end

  desc 'Purge messages in SQS queue for worker'
  task :purge => :config do
    @sqs.purge_queue(queue_url: @q_url)
    puts "Queue #{@q_name} purged"
  rescue StandardError => e
    puts "Error purging queue: #{e}"
  end
end

namespace :redis do
  desc 'Ping Redis to check the connection'
  task :ping => :config do
    require 'redis'
    require_relative 'config/environment' # load config info
    @api = LyricLab::App
    redis_url = @api.config.REDISCLOUD_URL
    redis = Redis.new(url: redis_url)

    begin
      response = redis.ping
      puts "Redis connection successful: #{response}"
    rescue StandardError => e
      puts "Error connecting to Redis: #{e.message}"
    end
  end
end
