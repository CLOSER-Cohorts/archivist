# The Strand model is a non-SQL database model that uses Redis to store
# its data. A Strand represents a collection of {CcQuestion Questions}
# and {Variable Variables} that form an interconnected collection of
# Mappable objects. It is used to control the application and linking of
# topics.
#
# === Properties
# * id
# * topic
# * members
# * good
class Strand < RedisRecord
  # Include basic Rails model functionality, without using an SQL database
  include ActiveModel::Model

  # The scope used for all keys in Redis
  SCOPE = 'mapper:strands'

  # The key of the lookup hash to quickly find Strands from member typedid
  LOOKUP = SCOPE + ':lookup'

  # The key of the hash storing the topics for each Strand
  TOPICS = SCOPE + ':topics'

  # The key of the hash storing the statuses for each Strand
  STATUS = SCOPE + ':status'

  # Make the id set and get-able
  attr_accessor :id

  # Make the topic set and get-able
  attr_accessor :topic

  # Make the list of members only get-able
  attr_reader :members

  # Make the good status only get-able
  attr_reader :good

  # A collection of all active Strands held in memory
  # @type [Hash]
  @active = {}

  # Returns a list of Strands from Redis
  #
  # @return [Array]
  def self.all
    super do |id|
      Strand.find id
    end
  end

  # Deletes all Strands from Redis
  #
  # Also deletes all {Cluster Clusters}
  def self.delete_all
    Cluster.delete_all
    all_keys = Strand.all_keys
    while all_keys.count > 0
      Strand.redis.del all_keys.pop(1000)
    end
    Strand.redis.del LOOKUP
    Strand.redis.del TOPICS
    Strand.redis.del STATUS
  end

  # Gets a Strand by id, either from active memory list or Redis
  #
  # @param [Integer] id Id of Strand to be retrieved
  # @return [Strand]
  def self.find(id)
    return @active.has_key?(id.to_i) ? @active[id.to_i] : Strand.new(id.to_i)
  end

  # Gets a Strand by a member mappable item
  #
  # @param [Mappable] member Member item to find by
  # @return [Strand]
  def self.find_by_member(member)
    begin
      @id ||= redis.hget LOOKUP, member.typed_id
    rescue Redis::CannotConnectError
      Rails.logger.warn 'Cannot connect to Redis [find_by_member]'
    end
    return nil if @id.nil?
    return Strand.find(@id.to_i)
  end

  # Rebuilds all Strands
  #
  # Causes all current Strands to be deleted, which
  # could be dangerous if users are using Archivist.
  def self.rebuild_all
    Strand.delete_all
    CcQuestion.includes(link: :topic).find_each { |qc| Strand.new([qc]).save }
    Variable.includes(link: :topic).find_each { |v| Strand.new([v]).save }

    begin
      Map.includes([:source, :variable]).where(source_type: CcQuestion.name).find_each do |map|
        s1 = Strand.find_by_member map.source
        s2 = Strand.find_by_member map.variable

        s3 = s1 + s2
        puts "Concatenating id \"#{map.source.id}\" and label \"#{map.source.label}\" with variable \"#{map.variable.name}(id: #{map.variable.id})\" ..."
        s3.save
      end
      Instrument.find_each { |i| i.send :register_prefix }
    rescue => e
      puts "Error: #{e.class} -> #{e.message}"
      raise
    end
  end

  # Returns the active Redis connection
  #
  # @return [Redis]
  def self.redis
    $redis
  end

  # Creates a new Strand
  #
  # @param [Array|Integer] thing Either an array of initial members or a Strand id
  # @return [Strand]
  def initialize(thing = [])
    @good = true
    if thing.is_a?(Integer) || thing.is_a?(String)
      @id = thing
      @members = []
      load
      self.class.active[@id.to_i] = self
    else
      thing = [thing] unless thing.is_a?(Array)
      @members = thing
      compile
      evaluate false
    end
  end

  # Merges two Strands into one 'new' Strand
  #
  # @param [Strand] other Second Strand to be merged
  # @return [Strand] New combined Strand
  def +(other)
    new_members = []
    new_members += @members
    new_members += other.members
    cluster&.delete
    other.cluster&.delete
    delete
    other.delete
    s = Strand.new new_members
    c = Cluster.new [s]
    c.save
    s
  end

  # Test if two Strands are the same
  #
  # Two Strands are considered equal if they have exactly the same members
  #
  # @param [Strand] other Second Strand to be compared
  # @return [Boolean] Whether the Strands are the same
  def ==(other)
    @members.map(&:typed_id).sort.join('') == other.members.map(&:typed_id).sort.join('')
  end

  # Retrieves the {Cluster} this Strand belongs to
  #
  # @return [Cluster] Cluster this Strand belongs to
  def cluster
    Cluster.find_by_strand self
  end

  # Deletes a Strand from both Redis and the active memory list
  def delete
    super do
      @members.each do |member|
        Strand.redis.hdel LOOKUP, member.typed_id
      end
      Strand.redis.hdel TOPICS, @id
    end
  end

  # Returns all members with explicit {Topic Topics}
  #
  # @return [Array] All members with fixed {Topic Topics}
  def get_fixed_points
    @members.map { |m| m.association(:topic).reload.nil? ? nil : {point: m, topic: m.topic} }.compact
  end

  # Load a Strand from Redis
  #
  # This only works if the id has been set
  #
  # @return [Strand] Loaded Strand
  def load
    unless @id.nil?
      typed_member_ids = Strand.redis.smembers(SCOPE + ':' + @id.to_s).map { |x| x.split(':') }.group_by(&:first).map { |c, xs| [c, xs.map(&:last)] }
      typed_member_ids.each do |typed_ids|
        @members += typed_ids.first.constantize.find_by_sql(
          [
            'SELECT x.*, l.topic_id FROM ' + typed_ids.first.tableize + ' x LEFT OUTER JOIN links l ON l.target_id = x.id AND target_type = ? WHERE x.id IN (?)',
            typed_ids.first.classify,
            typed_ids.last
          ]
        )
      end
      topic_ids = @members.map(&:topic_id).compact.uniq
      topics = Hash[Topic.find(topic_ids).collect { |t| [t.id, t] }]
      @members.each { |m| m.association(:topic).target = topics[m.topic_id] unless m.topic_id.nil? }
      topic_code = Strand.redis.hget TOPICS, @id
      unless topic_code.nil?
        @topic = Topic.find_by_code topic_code
      end
      @good = Strand.redis.hget STATUS, @id
    end
    self
  end

  # Resets the properties of the Strand
  def reset
    @id = nil
    @members = []
    @topic = nil
  end

  # Saves a Strand to Redis
  #
  # @param [Object] do_eval Whether to evaluate the Strand before saving
  # the Strand's topic
  def save (do_eval = false)
    begin
      if @id.nil?
        @id = Strand.redis.incr SCOPE + ':count'
        self.class.active[@id.to_i] = self
      end
      Strand.redis.sadd SCOPE + ':' + @id.to_s, @members.map(&:typed_id)
      @members.each do |member|
        Strand.redis.hset LOOKUP, member.typed_id, @id.to_s
      end
      evaluate if do_eval
      Strand.redis.hset TOPICS, @id, @topic.code unless @topic.nil?
      Strand.redis.hset STATUS, @id, @good
    rescue Redis::CannotConnectError => e
      Rails.logger.warn 'Failed to save Strand to Redis, no connection.'
    end
  end

  private  # Private methods

  # Returns the array of active Strands in memory
  #
  # @return [Hash]
  def self.active
    @active
  end

  # Takes the initial Strand members and walks all of the edges
  # until all the members have been found and added to the Strand
  def compile
    begin
      edges = []
      @members.each do |member|
        edges += member.strand_maps
      end
      edges.reject! { |e| @members.map(&:typed_id).include?(e.typed_id) }
      @members += edges
    end while edges.count > 0
  end

  # Assess the Strand and determine the topic
  #
  # Each member is checked, if no member has a {Topic}, then the
  # Strand has no {Topic}. If the members only have no {Topic}, or a
  # single {Topic} then that {Topic} becomes the Strand's {Topic}.
  # If the members have more than one {Topic}, the Strand's status
  # is set to bad.
  def evaluate(reload = true)
    @topic = nil
    @members.each do |member|
      member.association(:link).reload if reload
      @good &&= set_topic member.link&.topic
    end
  end

  # Sets the Strands {Topic}
  #
  # While setting the {Topic}, the current/previous {Topic} is
  # checked and if the new {Topic} is in conflict false is
  # returned, otherwise true is returned.
  #
  # @param [Topic] topic New {Topic} value
  # @return [Boolean] False if the new topic causes a conflict
  def set_topic(topic)
    return true if topic.nil?
    if @topic.nil?
      @topic = topic
    end
    @topic == topic
  end
end
