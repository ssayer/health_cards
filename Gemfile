# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in health_cards.gemspec
gemspec

gem 'rake', '~> 13.0'

group :development, :test do
  gem 'rubocop', '~> 1.5'
  gem 'rubocop-minitest', '~> 0.10.1', require: false
  gem 'rubocop-rake', '~> 0.5.1'
end

group :test do
  gem 'minitest', '~> 5.14'
  gem 'simplecov', require: false
end
