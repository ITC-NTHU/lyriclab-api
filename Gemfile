# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Configuration and Utilities
gem 'figaro', '~> 1.2'
gem 'ostruct'
gem 'pry'
gem 'rake'

# Data Validation
gem 'dry-struct', '~> 1.6'
gem 'dry-types', '~> 1.7'

# Web Application
gem 'logger', '~> 1.6'
gem 'puma', '~>6.0'
gem 'rack-session', '~> 0.3'
gem 'roda', '~>3.0'
gem 'slim', '~>4.0'

# Networking
gem 'http', '~> 5.2.0'

# Google API
gem 'google-cloud-translate-v2'

# Database
gem 'hirb'

# gem 'hirb-unicode' # incompatible with new rubocop
gem 'sequel', '~> 5.0'

# Word Processing
gem 'csv'
gem 'rexml', '>= 3.3.9'
gem 'tradsim'

group :development, :test do
  gem 'roo'
  gem 'sqlite3', '~> 1.0'
end

group :production do
  gem 'pg', '~> 1.2'
end

# Testing
group :test do
  gem 'minitest', '~> 5.20'
  gem 'minitest-rg', '~> 5.2'
  gem 'simplecov', '~> 0'
  gem 'vcr', '~> 6'
  gem 'webmock', '~> 3'

  gem 'headless', '~> 2.3'
  gem 'selenium-webdriver', '~> 4.11'
  gem 'watir', '~> 7.0'
end

# Development
group :development do
  gem 'flog'
  gem 'reek'
  gem 'rerun'
  gem 'rubocop'
  gem 'rubocop-minitest'
  gem 'rubocop-rake'
  gem 'rubocop-sequel'
  gem 'ruby-lsp'
end

# gpt language
gem 'rest-client', '~> 2.1'
gem 'ruby-openai', '~> 6.3'
