# frozen_string_literal: true

require 'rake/testtask'

CODE = 'app/'

task :default do
  puts `rake -T`
end

desc 'Run web app'
task :run do
  sh 'bundle exec puma'
end

desc 'Keep rerunnin web app upoon changes'
task :rerun do
  sh "rerun -c --ignore 'coverage/*' -- bundle exec puma"
end

desc 'run tests'
task :spec do
  sh 'ruby spec/gateway_lrclib_spec.rb'
  sh 'ruby spec/gateway_spotify_spec.rb'
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
  desc 'run all static-analysis quality checks'
  task all: %i[rubocop reek flog]

  desc 'code style linter'
  task :rubocop do
    sh 'rubocop $(find . -name \'*.rb\')'
  end

  desc 'code smell detector'
  task :reek do
    sh 'reek'
  end

  desc 'complexity analysis'
  task :flog do
    sh "flog #{CODE}"
  end
end
