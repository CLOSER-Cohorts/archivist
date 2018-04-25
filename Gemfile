source 'https://rubygems.org'

ruby '2.4.3'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'angular-rails-templates', '~> 1.0'
# Allows the attaching of AWS buckets
gem 'aws-sdk', '~> 2'
# Use Bower to manage JavaScript assets
gem 'bower-rails'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.0'
gem 'coveralls', require: false
# To search for memory leaks and memory bloat
gem 'derailed'
# Use Devise for authentication
gem "devise"
# To better enable custom configurations
gem 'figaro'
# Used in DataTools
gem 'fuzzy_match'
# TODO: Should this be managed through Bower
gem "genericons-rails"
# Automatically scales dynos
gem "hirefire-resource"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
gem 'jbuilder_cache_multi'
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'json'
# Faster JavaScript/JSON converter
gem 'oj'
# TODO: Are we using this?
gem 'parallel'
# Use Postgres as the database for Active Record
gem 'pg', '0.21.0'
# Heroku email service
gem 'postmark-rails', '>= 0.10.0'
# Use Puma as the web server
gem 'puma', '~>2.16.0'
# Pundit for
gem "pundit"
# Limits processing time in rack layer for added loading protection
gem 'rack-timeout'
gem 'rails', '~>5.0.0'
# Use Redis for caching
gem 'redis', '~>3.3.2'
# Create background workers
gem 'resque'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Production gems
group :production do
  # Heroku logging
  gem 'rails_12factor'
  gem 'redis-rack-cache'
  # Use Skylight for realtime response analytics
  gem 'skylight'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'derailed_benchmarks', '~> 1.3', '>= 1.3.2'
  gem 'stackprof', group: :development
  gem 'sys-proctable', platforms: [:mingw, :mswin, :x64_mingw]
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
end

group :development do
  gem 'db_fixtures_dump'
  gem 'rails-erd'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'minitest', '~> 5.10', '!= 5.10.2'
  # Performance testing
  #gem 'rails-perftest'
  #gem 'ruby-prof'
  gem 'rails-controller-testing'
  gem 'resque_unit'
end
