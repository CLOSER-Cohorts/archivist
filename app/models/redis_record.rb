# An abstract class for all Redis-backed models to
# derive from
class RedisRecord

  class SCOPE; end
  # Returns a list of all items from Redis
  #
  # @return [Array]
  def self.all
    all_keys = RedisRecord.all_keys

    all_ids = all_keys.map { |x| x.split(':').last.to_i }
    all_keys = []
    all_ids.each do |id|
      c = yield id
      all_keys << c unless c.nil?
    end
    all_keys
  end

  # Returns all the keys from Redis
  #
  # @return [Array]
  def self.all_keys
    all_keys = []
    iterator = 0
    begin
      iterator, results = RedisRecord.redis.scan iterator, {match: self::SCOPE.to_s + ':[0-9]*', count: 10000}
      all_keys += results
    end while iterator.to_i != 0
    all_keys
  end

  # Returns the active Redis connection
  #
  # @return [Redis]
  def self.redis
    $redis
  end

  # Deletes the item from both Redis and the active memory list
  def delete
    self.class.active.delete(@id.to_i)
    unless @id.nil?
      RedisRecord.redis.del self.class::SCOPE.to_s + ':' + @id.to_s
      yield
    end
    reset
  end
end
