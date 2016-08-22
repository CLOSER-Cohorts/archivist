# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
require 'rack'
require 'rack/cache'
require 'redis-rack-cache'

use Rack::Deflater
use Rack::Cache,
    metastore: ((ENV["REDIS_URL"] + '/1') || 'redis://127.0.0.1:6379/0') + '/metastore',
    entitystore: ((ENV["REDIS_URL"] + '/1') || 'redis://127.0.0.1:6379/0') + '/entitystore'

run Rails.application
