class Cluster
  SCOPE = 'mapper:clusters'
  LOOKUP = SCOPE + ':lookup'
  TOPICS = SCOPE + ':suggested_topics'

  include ActiveModel::Model

  attr_accessor :id, :suggested_topic
  attr_reader :strands

  @@active = {}

  def initialize(thing = [])
    if thing.is_a?(Integer) || thing.is_a?(String)
      @id = thing
      @strands = []
      load
      @@active[@id.to_i] = self
    else
      thing = [thing] unless thing.is_a?(Array)
      @strands = thing
      evaluate
    end
  end

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

  def save(do_eval = false)
    if @id.nil?
      @id = Cluster.redis.incr SCOPE + ':count'
      @@active[@id.to_i] = self
    end
    Cluster.redis.sadd SCOPE + ':' + @id.to_s, @strands.map(&:id)
    @strands.each do |strand|
      Cluster.redis.hset LOOKUP, strand.id, @id.to_s
    end
    evaluate if do_eval
    Cluster.redis.hset TOPICS, @id, @suggested_topic.code unless @suggested_topic.nil?
  end

  def delete
    @@active.delete(@id.to_i)
    unless @id.nil?
      Cluster.redis.del SCOPE + ':' + @id.to_s
      @strands.each do |strand|
        Cluster.redis.hdel LOOKUP, strand.id
      end
      Cluster.redis.hdel TOPICS, @id
    end
    @strands = []
    @id = nil
    @topic = nil
  end

  def +(other)
    new_members = []
    new_members += @strands
    new_members += other.strands
    delete
    other.delete
    Cluster.new new_members
  end

  def self.find(id)
    return @@active.has_key?(id.to_i) ? @@active[id.to_i] : Cluster.new(id.to_i)
  end

  def self.find_by_strand(strand)
    id = redis.hget LOOKUP, strand.id
    return nil if id.nil?
    return Cluster.find(id.to_i)
  end

  def self.find_by_member(member)
    strand = Strand.find_by_member member
    return find_by_strand strand unless strand.nil?
    return nil
  end

  def self.all
    all_clusters = Cluster.all_keys

    all_ids = all_clusters.map { |x| x.split(':').last.to_i }
    all_clusters = []
    all_ids.each do |id|
      c = Cluster.find id
      all_clusters << c unless c.nil?
    end
  end

  def self.all_keys
    all_keys = []
    iterator = 0
    begin
      iterator, results = Cluster.redis.scan iterator, {match: SCOPE + ':[0-9]*', count: 10000}
      all_keys += results
    end while iterator.to_i != 0
    all_keys
  end

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

  private
  def evaluate
    counter = Hash.new 0
    @strands.each do |strand|
      next unless strand.good
      next if strand.topic.nil?

      counter[strand.topic] += 1
    end
    puts "strands: " + @strands.inspect.to_s
    puts "counter: " + counter.inspect.to_s
    puts "suggested topic: " + @suggested_topic.inspect.to_s
    topic, count = counter.max_by { |k, v| v }
    @suggested_topic = count.to_i > 0 ? topic : nil
  end

  def self.delete_all
    all_keys = Cluster.all_keys
    while all_keys.count > 0
      Cluster.redis.del all_keys.pop(1000)
    end
    Cluster.redis.del LOOKUP
    Cluster.redis.del TOPICS
  end

  def self.redis
    $redis
  end
end