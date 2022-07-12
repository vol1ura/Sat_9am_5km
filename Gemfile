# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

gem 'importmap-rails', '~> 1.1'
gem 'sassc-rails'

gem 'rails', '~> 7.0.3'

gem 'activeadmin'
gem 'bootstrap', '~> 5.1.3'
gem 'cancancan', '~> 3.3'
gem 'devise', '~> 4.8'
gem 'devise-i18n'
gem 'jbuilder'
gem 'nokogiri'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'sprockets-rails'
gem 'turbo-rails', '~> 1.1'

group :development, :test do
  gem 'brakeman'
  gem 'bullet'
  gem 'bundler-audit'
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'faker', git: 'https://github.com/faker-ruby/faker.git', branch: 'master'
  gem 'mini_racer' # add node to docker and remove racer
  gem 'rspec-rails', '~> 6.0.0.rc'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false

  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '>= 3.26'
  # gem 'selenium-webdriver'
end

group :test do
  gem 'simplecov', require: false
  gem 'webmock', require: false
end

group :development do
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'rack-mini-profiler'

  gem 'capistrano', '~> 3.17', require: false
  gem 'capistrano3-puma', require: false
  # gem 'capistrano-postgresql', '~> 6.2', require: false
  gem 'capistrano-rails', '~>1.6', require: false
  gem 'capistrano-rbenv', '~>2.2.0', require: false

  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
  gem 'ed25519', '>= 1.2', '< 2.0'
end
