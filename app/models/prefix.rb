class Prefix
  class << self
    def [](prefix)
      begin
        if (id = redis.hget hash, prefix).nil?
          prefix
        else
          id
        end
      rescue Exception => e
        Rails.logger.warn 'Unable to get prefix from Redis cache. Returning input.'
        Rails.logger.warn e.message
        return prefix
      end
    end

    def []=(prefix, id)
      begin
        redis.hset hash, prefix, id
      rescue Exception => e
        Rails.logger.warn 'Unable to save prefix to Redis cache'
        Rails.logger.warn e.message
      end
    end

    def destroy(prefix)
      begin
        redis.hdel hash, prefix
      rescue Exception => e
        Rails.logger.warn 'Unable to delete prefix from Redis cache'
        Rails.logger.warn e.message
      end
    end

    private
    def hash
      'instrument_ids'
    end

    def redis
      $redis
    end
  end
end