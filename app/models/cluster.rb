# The Cluster model is a non-SQL database model that uses Redis to store
# its data. A Cluster represents a collection of Strands that form an
# interconnected collection of Mappable objects. It is used to control
# the application and linking of topics.
#
# === Properties
# * id
# * suggested_topic
# * strands
class Cluster
  # Include basic Rails model functionality, without using an SQL database
  include ActiveModel::Model

  # The scope used for all keys in Redis
  SCOPE = 'mapper:clusters'

  # The key of the lookup hash to quickly find Clusters from {Strand} id
  LOOKUP = SCOPE + ':lookup'

  # The key of the hash storing the suggested_topics for each Cluster
  TOPICS = SCOPE + ':suggested_topics'

  # Make the id set and get-able
  attr_accessor :id

  # Make the suggested_topic set and get-able
  attr_accessor :suggested_topic

  # Make the list of strands only get-able
  attr_reader :strands

  # A collection of all active Clusters held in memory
  # @type [Hash]
  @active = {}

  # Returns a list of Clusters from Redis
  #
  # @return [Array]
  def self.all
    super do |id|
      Cluster.find id
    end
  end

  # Deletes all Clusters from Redis
  def self.delete_all
    all_keys = Cluster.all_keys
    while all_keys.count > 0
      Cluster.redis.del all_keys.pop(1000)
    end
    Cluster.redis.del LOOKUP
    Cluster.redis.del TOPICS
  end

  # Gets a Cluster by id, either from active memory list or Redis
  #
  # @param [Integer] id Id of Cluster to be retrieved
  # @return [Cluster]
  def self.find(id)
    return @active.has_key?(id.to_i) ? @active[id.to_i] : Cluster.new(id.to_i)
  end

  # Gets a Cluster by a member mappable item
  #
  # @param [Mappable] member Member item to find by
  # @return [Cluster]
  def self.find_by_member(member)
    strand = Strand.find_by_member member
    return find_by_strand strand unless strand.nil?
    return nil
  end

  # Gets a cluster by a constituent Strand
  #
  # @param [Strand] strand Strand to find by
  # @return [Cluster]
  def self.find_by_strand(strand)
    id = redis.hget LOOKUP, strand.id
    return nil if id.nil?
    return Cluster.find(id.to_i)
  end

  # Rebuilds all Clusters and Strands
  #
  # Causes all current Strands and Clusters to be deleted, which
  # could be dangerous if users are using Archivist.
  def self.rebuild_all
    Strand.rebuild_all

    Strand.all.each { |s| Cluster.new([s]).save }

    Map.where(source_type: Variable.name).find_each do |map|
      c1 = Cluster.find_by_member map.source
      c2 = Cluster.find_by_member map.variable

      c3 = c1 + c2
      c3.save
    end
  end

  # Returns the active Redis connection
  #
  # @return [Redis]
  def self.redis
    $redis
  end

  # Creates a new Cluster
  #
  # @param [Array|Integer] thing Either an array of initial Strands or a Cluster id
  # @return [Cluster]
  def initialize(thing = [])
    if thing.is_a?(Integer) || thing.is_a?(String)
      @id = thing
      @strands = []
      load
      self.class.active[@id.to_i] = self
    else
      thing = [thing] unless thing.is_a?(Array)
      @strands = thing
      compile
    end
  end

  # Merges two Clusters into one 'new' Cluster
  #
  # @param [Cluster] other Second Cluster to be merged
  # @return [Cluster] New combined Cluster
  def +(other)
    new_members = []
    new_members += @strands
    new_members += other.strands
    delete
    other.delete
    Cluster.new new_members
  end

  # Returns all Mappable members that belong to this Cluster
  #
  # @return [Array]
  def all_members
    @strands.map { |s| s.members }.flatten
  end

  # Compile works through all members to generate the full Cluster
  #
  # A complete list of Strands is created by checking each member
  # recursively until all edges have been explored and added to the
  # Cluster. Then evaluate is called to deteremine the suggested_topic
  def compile
    queue = all_members
    while queue.count > 0
      found_strands = queue.shift.cluster_maps.map do |obj|
        obj.strand(false)
      end
      found_strands.reject! { |s| @strands.include?(s) }
      @strands += found_strands
      queue += found_strands.map(&:members).flatten
    end
    evaluate
  end

  # Deletes a Cluster from both Redis and the active memory list
  def delete
    super do
      @strands.each do |strand|
        Cluster.redis.hdel LOOKUP, strand.id
      end
      Cluster.redis.hdel TOPICS, @id
    end
  end

  # Load a Cluster from Redis
  #
  # This only works if the id has been set
  #
  # @return [Cluster] Loaded Cluster
  def load
    unless @id.nil?
      Cluster.redis.smembers(SCOPE + ':' + @id.to_s).each do |strand_id|
        strand = Strand.find strand_id
        @strands.push strand unless strand.nil?
      end
      topic_code = Cluster.redis.hget TOPICS, @id
      unless topic_code.nil?
        @suggested_topic = Topic.find_by_code topic_code
      end
    end
    self
  end

  # Resets the properties of the Cluster
  def reset
    @id = nil
    @strands = []
    @suggested_topic = nil
  end

  # Broadcasts a batch update using archivist-realtime for
  # all Cluster members
  def rt_update
    Realtime::Publisher.instance.batch_update all_members
  end

  # Saves a Cluster to Redis
  #
  # @param [Object] do_eval Whether to evaluate the Cluster before saving
  # the Cluster's topic
  def save(do_eval = false)
    begin
      if @id.nil?
        @id = Cluster.redis.incr SCOPE + ':count'
        self.class.active[@id.to_i] = self
      end
      @strands.each do |strand|
        strand.save
        Cluster.redis.hset LOOKUP, strand.id, @id.to_s
      end
      Cluster.redis.sadd SCOPE + ':' + @id.to_s, @strands.map(&:id)
      evaluate if do_eval
      Cluster.redis.hset TOPICS, @id, @suggested_topic.code unless @suggested_topic.nil?
    rescue Redis::CannotConnectError => e
      Rails.logger.warn 'Failed to save Cluster to Redis, no connection.'
    end
  end

  private # Private methods

  # Returns the array of active Clusters in memory
  #
  # @return [Hash]
  def self.active
    @active
  end

  # Assess the Cluster and determine the suggested_topic
  #
  # The frequency of each Topic used by a Mappable member is
  # calculated and the topic with the most uses becomes the
  # suggested topic for the Cluster.
  #
  # TODO: Should this algorithm take into account Strand size?
  def evaluate
    counter = Hash.new 0
    @strands.each do |strand|
      next unless strand.good
      next if strand.topic.nil?

      counter[strand.topic] += 1
    end
    topic, count = counter.max_by { |k, v| v }
    @suggested_topic = count.to_i > 0 ? topic : nil
  end
end