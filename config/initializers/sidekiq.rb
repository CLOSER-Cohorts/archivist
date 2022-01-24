Sidekiq.configure_server do |config|
  config.redis = {url: ENV.fetch("REDIS_URL", "redis://localhost"), namespace: "archivist:sidekiq", ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }}
end

Sidekiq.configure_client do |config|
  config.redis = {url: ENV.fetch("REDIS_URL", "redis://localhost"), namespace: "archivist:sidekiq", ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }}
end
