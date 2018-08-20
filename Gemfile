source 'https://rubygems.org'

ruby '2.5.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'angular-rails-templates', '1.0.2'
# Allows the attaching of AWS buckets
gem 'aws-sdk', '2.10.101'
# Use Bower to manage JavaScript assets
gem 'bower-rails', '0.11.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '4.2.2'
gem 'coveralls', '0.8.21', require: false
# To search for memory leaks and memory bloat
gem 'derailed', '0.1.0'
# Use Devise and Pundit for authentication and authorization respectively
gem 'devise', '4.4.0'
# To better enable custom configurations
gem 'figaro', '1.1.1'
# Used in DataTools
gem 'fuzzy_match', '2.1.0'
# TODO: Should this be managed through Bower
gem 'genericons-rails', '0.5.0'
# Heroku-deflater compresses assets and application responses on Heroku, while not wasting CPU cycles
# on pointlessly compressing images and other binary responses
gem 'heroku-deflater', '~> 0.6.3', :group => :production
# Automatically scales dynos
gem 'hirefire-resource', '0.4.2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '2.7.0'
gem 'jbuilder_cache_multi', '0.1.0'
# Use jquery as the JavaScript library
gem 'jquery-rails', '4.3.1'
gem 'json', '1.8.6'
# Faster JavaScript/JSON converter
gem 'oj', '3.3.9'
# TODO: Are we using this?
gem 'parallel', '1.12.0'
# Use Postgres as the database for Active Record
gem 'pg', '0.21.0'
# Heroku email service
gem 'postmark-rails', '0.15.0'
# Use Puma as the web server
gem 'puma', '2.16.0'
gem 'pundit', '1.1.0'
# Limits processing time in rack layer for added loading protection
gem 'rack-timeout', '0.4.2'
gem 'rails', '5.0.6'
# Use Redis for caching
gem 'redis', '3.3.5'
# Create background workers
gem 'resque', '1.27.4'
# Use SCSS for stylesheets
gem 'sass-rails', '5.0.7'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '0.4.2', group: :doc
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '4.1.18'

# Production gems
group :production do
  # Heroku logging
  gem 'rails_12factor', '0.0.3'
  gem 'redis-rack-cache', '2.0.2'
  # Use Skylight for realtime response analytics
  gem 'skylight', '1.5.0'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '9.1.0'
  gem 'derailed_benchmarks', '~> 1.3', '>= 1.3.2'
  gem 'pry-rails', '~> 0.3.6'
  gem 'stackprof', group: :development
  gem 'sys-proctable', platforms: [:mingw, :mswin, :x64_mingw]
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
end

group :development do
  gem 'db_fixtures_dump', '0.1.1'
  gem 'rails-erd', '1.5.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '2.0.2'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '2.3.0'
end

group :test do
  gem 'minitest', '5.10.3', '!= 5.10.2'
  # Performance testing
  #gem 'rails-perftest'
  #gem 'ruby-prof'
  gem 'rails-controller-testing', '1.0.2'
  gem 'resque_unit'
  gem 'simplecov', require: false, group: :test
end
