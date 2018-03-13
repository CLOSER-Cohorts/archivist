# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
require 'rack'
require 'rack/cache'
require 'redis-rack-cache'

run Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, ['get rack\'d']] }

use Rack::Deflater
use Rack::Cache,
    metastore: (ENV["REDIS_URL"] || 'redis://127.0.0.1:6379') + '/1/metastore',
    entitystore: (ENV["REDIS_URL"] || 'redis://127.0.0.1:6379') + '/1/entitystore'
use Rack::Reloader, 0

run Rails.application
