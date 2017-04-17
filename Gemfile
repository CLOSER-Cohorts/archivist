source 'http://rubygems.org'

ruby '2.3.1'

gem 'rails', '~>5.0.0'
gem 'json'
gem 'jazz_hands', github: 'vwall/jazz_hands'

# Use Puma as the web server
gem 'puma', '~>2.16.0'

# Use Postgres as the database for Active Record
gem 'pg'

# Use Redis for caching
gem 'redis'

# Production gems
group :production do
  # Heroku logging
  gem 'rails_12factor'
  gem 'redis-rack-cache'

  # Use Skylight for realtime response analytics
  gem 'skylight'
end

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# TODO: Should this be managed through Bower
gem "genericons-rails"

# Use Devise and Pundit for authentication and authorization respectively
gem "devise"
gem "pundit"

# Use Bower to manage JavaScript assets
gem 'bower-rails'

gem 'angular-rails-templates', '~> 1.0'

# TODO: Are we using this?
gem 'parallel'

# Faster JavaScript/JSON converter
gem 'oj'
gem 'jbuilder_cache_multi'

# Heroku email service
gem 'postmark-rails', '>= 0.10.0'

# Limits processing time in rack layer for added loading protection
gem 'rack-timeout'

# Create background workers
gem 'resque'

# Automatically scales dynos
gem "hirefire-resource"

# Allows the attaching of AWS buckets
gem 'aws-sdk', '~> 2'

# To search for memory leaks and memory bloat
gem 'derailed'

# To better enable custom configurations
gem 'figaro'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
  gem 'sys-proctable', platforms: [:mingw, :mswin, :x64_mingw]
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rails-erd'
  gem 'db_fixtures_dump'
end

group :test do
  # Performance testing
  #gem 'rails-perftest'
  #gem 'ruby-prof'
  gem 'rails-controller-testing'
  gem 'resque_unit'
end

gem 'coveralls', require: false
