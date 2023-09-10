# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

gem 'importmap-rails', '~> 1.2'
gem 'sassc-rails'

gem 'rails', '~> 7.0.4'

gem 'activeadmin'
gem 'activeadmin_quill_editor'
gem 'audited'
gem 'barby', require: false
gem 'bootstrap', '~> 5.3.1'
gem 'cancancan', '~> 3.4'
gem 'dalli'
gem 'devise', '~> 4.8'
gem 'devise-i18n'
gem 'hotwire-rails'
gem 'jbuilder'
gem 'nokogiri'
gem 'pg', '~> 1.4'
gem 'puma', '~> 5.6'
gem 'rails_performance'
gem 'sidekiq'
gem 'sprockets-rails'

gem 'hiredis-client'
gem 'redis'

gem 'rollbar'

group :development, :test do
  gem 'brakeman'
  gem 'bullet'
  gem 'bundler-audit'
  gem 'factory_bot_rails'
  gem 'faker', git: 'https://github.com/faker-ruby/faker.git', branch: 'master'
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'webmock', require: false
end

group :development do
  gem 'database_consistency', require: false
  gem 'rack-mini-profiler'

  # Deploy
  gem 'capistrano', '~> 3.17', require: false
  gem 'capistrano3-puma', require: false
  gem 'capistrano-rails', '~> 1.6', require: false
  gem 'capistrano-rbenv', '~> 2.2', require: false
  gem 'capistrano-sidekiq', '~> 2.3', require: false

  gem 'bcrypt_pbkdf', '~> 1.0'
  gem 'ed25519', '~> 1.3'
end
