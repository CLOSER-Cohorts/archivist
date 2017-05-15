class Identifier < ApplicationRecord
  after_create :add_to_cache
  belongs_to :item, polymorphic: true
  validates :item, presence: true

  # Returns all the keys of Identifier lookups in Redis
  #
  # @return [Array]
  def self.all_keys
    all_keys = []
    iterator = 0
    begin
      iterator, results = Cluster.redis.scan iterator, {match: 'identifier:*', count: 10000}
      all_keys += results
    end while iterator.to_i != 0
    all_keys
  end

  def self.clear_cache
    all_keys.each do |key|
      redis.del key
    end
    redis.del 'identifiers'
  end

  def self.populate_cache
    Identifier.find_each do |identifier|
      identifier.add_to_cache
    end
  end

  def readonly?
    !new_record?
  end

  protected
  def typed_id
    self.id_type + ':' + self.value
  end

  private
  def add_to_cache
    redis.hset 'identifiers', self.typed_id, item.typed_id
    redis.sadd 'identifier:' + item.typed_id, self.typed_id
  end

  def redis
    $redis
  end
end
