source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "barnes"
gem "bootsnap", require: false
gem 'e164'
gem 'oj'
gem "olive_branch"
gem "omniauth-auth0"
gem 'omniauth-rails_csrf_protection'
gem "pg", "~> 1.1"
gem "premailer-rails"
gem "puma", "~> 6.0"
gem "rack-cors"
gem "rails", "~> 7.1", ">= 7.1"
gem "redis"
gem 'rswag-api'
gem 'rswag-ui'
gem 'scout_apm'
gem "sentry-rails"
gem "sentry-ruby"
gem 'sidekiq'
gem 'slack-ruby-client'
gem "sprockets-rails"
gem "strong_migrations"
gem "twilio-ruby"
gem 'value_semantics'

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem 'faker'
  gem "pry"
  gem 'pry-byebug'
  gem "rspec-rails"
  gem 'rswag-specs'
  gem "rubocop"
  gem 'rubocop-factory_bot'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development do
  gem 'annotate'
  gem "spring"
  gem 'spring-commands-rspec'
  gem "web-console"
end

group :test do
  gem 'database_cleaner-active_record'
end
