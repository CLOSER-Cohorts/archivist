$redis = Redis.new(url: ENV["REDIS_URL"] || 'redis://127.0.0.1:6379/0')
