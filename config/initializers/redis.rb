$redis = Redis.new( url: ENV['REDIS_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } )
Sidekiq.configure_server do |config|
  config.redis = $redis
end

Sidekiq.configure_client do |config|
  config.redis = $redis
end
