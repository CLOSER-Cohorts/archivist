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
        logger.warn 'Unable to get prefix from Redis cache. Returning input.'
        logger.warn e.message
        return id
      end
    end

    def []=(prefix, id)
      begin
        redis.hset hash, prefix, id
      rescue Exception => e
        logger.warn 'Unable to save prefix to Redis cache'
        logger.warn e.message
      end
    end

    def destroy(prefix)
      begin
        redis.hdel hash, prefix
      rescue Exception => e
        logger.warn 'Unable to delete prefix from Redis cache'
        logger.warn e.message
      end
    end

    private
    def redis
      $redis
    end

    def hash
      'instrument_ids'
    end
  end
end