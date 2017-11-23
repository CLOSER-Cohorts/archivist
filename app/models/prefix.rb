# The Prefix model is a pure Redis cache model that allows an
# {Instrument Instruments} prefix to be used instead of an id
# during routing
#
# Prefix acts as a singleton class
class Prefix
  class << self
    # Access operator to retrieve an {Instrument} id using a prefix from the cache
    #
    # @param [String] prefix Instrument prefix
    # @return [String] Instrument id
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

    # Setting operator to add an {Instrument} prefix to the cahce
    #
    # @param [String] prefix {Instrument} prefix
    # @param [Integer] id {Instrument} id
    def []=(prefix, id)
      begin
        redis.hset hash, prefix, id
      rescue Exception => e
        Rails.logger.warn 'Unable to save prefix to Redis cache'
        Rails.logger.warn e.message
      end
    end

    # Removes a prefix from the cache
    def destroy(prefix)
      begin
        redis.hdel hash, prefix
      rescue Exception => e
        Rails.logger.warn 'Unable to delete prefix from Redis cache'
        Rails.logger.warn e.message
      end
    end

    private # Private method
    # Returns key of hash in Redis
    #
    # @return [String] Redis key of hash storing prefixes
    def hash
      'instrument_ids'
    end

    # Wraps the global connection to the Redis cache
    #
    # @return [Redis] Redis connection
    def redis
      $redis
    end
  end
end