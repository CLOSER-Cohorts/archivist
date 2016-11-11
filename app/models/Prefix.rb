class Prefix
  class << self
    def [](prefix)
      if (id = redis.hget hash, prefix).nil?
        prefix
      else
        id
      end
    end

    def []=(prefix, id)
      redis.hset hash, prefix, id
    end

    def destroy(prefix)
      redis.hdel hash, prefix
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