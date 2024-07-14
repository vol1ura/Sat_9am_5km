# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.2'

gem 'rails', '~> 7.1.2'

gem 'activeadmin'
gem 'activeadmin_quill_editor'
gem 'activeadmin-searchable_select'
gem 'active_storage_validations'
gem 'audited'
gem 'bootsnap', require: false
gem 'bootstrap', '~> 5.3.3'
gem 'cancancan'
gem 'connection_pool'
gem 'dalli'
gem 'dartsass-sprockets'
gem 'devise', '~> 4.8'
gem 'devise-i18n'
gem 'font-awesome-sass'
gem 'hotwire_combobox'
gem 'hotwire-rails'
gem 'image_processing'
gem 'importmap-rails', '~> 1.2'
gem 'jbuilder'
gem 'nokogiri'
gem 'pg'
gem 'puma'
gem 'rack-attack'
gem 'rails_performance'
gem 'rqrcode', require: false
gem 'ruby-vips', '>= 2.1.0'
gem 'sidekiq'
gem 'sitemap_generator'
gem 'sprockets-rails'
gem 'whenever', require: false

gem 'hiredis-client'
gem 'redis'

gem 'rollbar'

group :development, :test do
  gem 'brakeman'
  gem 'bullet'
  gem 'bundler-audit'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'rspec-rails'
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
  gem 'capistrano3-puma', '6.0.0.beta.1', require: false
  gem 'capistrano-rails', '~> 1.6', require: false
  gem 'capistrano-rbenv', '~> 2.2', require: false
  gem 'capistrano-sidekiq', '~> 2.3', require: false

  gem 'bcrypt_pbkdf', '~> 1.0'
  gem 'ed25519', '~> 1.3'
end
