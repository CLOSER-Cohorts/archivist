# Any exportable item can have an unlimited number of Identifiers
#
# Identifiers are to ensure persistent identifiers can be created during
# import and export. They can be used as URNs or any other form of string
# based of unique identification. Each ID string must be unqiue within a
# type.
class Identifier < ApplicationRecord
  # After creating an identifier, it is added to the Redis cache
  after_create :add_to_cache

  # After destroying an identifier, it is removed from the Redis cache
  after_destroy :remove_from_cache

  # Every identifier must belong to an importable/exportable item
  belongs_to :item, polymorphic: true

  # Validates that an identifier has an item before saving
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

  # Clears the entire Redis cache of identifiers, does not effect
  # the database
  def self.clear_cache
    all_keys.each do |key|
      redis.del key
    end
    redis.del 'identifiers'
  end

  # Fills the cache with the identifiers to boost performance
  def self.populate_cache
    Identifier.find_each do |identifier|
      identifier.add_to_cache
    end
  end

  # Identifiers are readonly and should never be editted or deleted
  #def readonly?
  #  !new_record?
  #end

  protected # Protected methods
  # Joins the ID type and value using a colon
  #
  # @return [String] {type}:{value}
  def typed_id
    self.id_type + ':' + self.value
  end

  private # Private methods
  # Inserts ID into the Redis cache
  def add_to_cache
    redis.hset 'identifiers', self.typed_id, item.typed_id
    redis.sadd 'identifier:' + item.typed_id, self.typed_id
  end

  # Wraps the global connection to the Redis cache
  #
  # @return [Redis] Redis connection
  def redis
    $redis
  end

  # Removes ID into the Redis cache
  def remove_from_cache
    redis.hdel 'identifiers', self.typed_id
    redis.srem 'identifier:' + item.typed_id, self.typed_id
  end
end
