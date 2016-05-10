source 'https://rubygems.org'

ruby '2.2.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.1'
gem 'json', '1.8.2'

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
end

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem "genericons-rails"
gem "devise"
gem "pundit"
gem 'bower-rails'
gem 'angular-rails-templates', '0.2.0'
gem 'skylight'
gem 'parallel'
gem 'oj'
gem 'jbuilder_cache_multi'
gem 'postmark-rails', '>= 0.10.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
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
  gem 'rails-perftest'
  gem 'ruby-prof'
end

gem 'coveralls', require: false