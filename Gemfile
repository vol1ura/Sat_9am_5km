# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'sass-rails', '>= 6'

gem 'rails', '~> 7.0.3'

gem 'activeadmin'
gem 'cancancan', '~> 3.3'
gem 'devise', '~> 4.8'
gem 'devise-i18n'
gem 'jbuilder'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'sprockets-rails'

group :development, :test do
  gem 'bullet'
  gem 'byebug', require: false
  gem 'factory_bot_rails'
  gem 'faker', git: 'https://github.com/faker-ruby/faker.git', branch: 'master'
  gem 'rspec-rails', '~> 6.0.0.rc'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false

  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '>= 3.26'
  # gem 'selenium-webdriver'
end

group :development do
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'rack-mini-profiler'
end
