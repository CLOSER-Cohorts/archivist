class Strand
  include ActiveModel::Model

  SCOPE = 'mapper:strands'
  LOOKUP = SCOPE + ':lookup'
  TOPICS = SCOPE + ':topics'
  STATUS = SCOPE + ':status'

  attr_accessor :id, :topic
  attr_reader :members, :good

  @active = {}

  def self.all
    all_strands = Strand.all_keys

    all_ids = all_strands.map { |x| x.split(':').last.to_i }
    all_strands = []
    all_ids.each do |id|
      c = Strand.find id
      all_strands << c unless c.nil?
    end
    all_strands
  end

  def self.all_keys
    all_keys = []
    iterator = 0
    begin
      iterator, results = Strand.redis.scan iterator, {match: SCOPE + ':[0-9]*', count: 10000}
      all_keys += results
    end while iterator.to_i != 0
    all_keys
  end

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

  def self.find(id)
    return @active.has_key?(id.to_i) ? @active[id.to_i] : Strand.new(id.to_i)
  end

  def self.find_by_member(member)
    begin
      id = redis.hget LOOKUP, member.typed_id
    rescue Redis::CannotConnectError
      Rails.logger.warn 'Cannot connect to Redis'
    end
    return nil if id.nil?
    return Strand.find(id.to_i)
  end

  def self.rebuild_all
    Strand.delete_all
    CcQuestion.includes(link: :topic).find_each { |qc| Strand.new([qc]).save }
    Variable.includes(link: :topic).find_each { |v| Strand.new([v]).save }

    Map.includes([:source, :variable]).where(source_type: CcQuestion.name).find_each do |map|
      s1 = Strand.find_by_member map.source
      s2 = Strand.find_by_member map.variable

      s3 = s1 + s2
      s3.save
    end
  end

  def self.redis
    $redis
  end

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

  def ==(other)
    @members.map(&:typed_id).sort.join('') == other.members.map(&:typed_id).sort.join('')
  end

  def cluster
    Cluster.find_by_strand self
  end

  def delete
    self.class.active.delete(@id.to_i)
    unless @id.nil?
      Strand.redis.del SCOPE + ':' + @id.to_s
      @members.each do |member|
        Strand.redis.hdel LOOKUP, member.typed_id
      end
      Strand.redis.hdel TOPICS, @id
    end
    @members = []
    @id = nil
    @topic = nil
  end

  def get_fixed_points
    @members.map { |m| m.association(:topic).reload.nil? ? nil : {point: m, topic: m.topic} }.compact
  end

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

  def save (do_eval = false)
    if @id.nil?
      @id = Strand.redis.incr SCOPE + ':count'
      self.class.active[@id.to_i] = self
    end
    puts @members.map(&:typed_id).inspect
    Strand.redis.sadd SCOPE + ':' + @id.to_s, @members.map(&:typed_id)
    @members.each do |member|
      Strand.redis.hset LOOKUP, member.typed_id, @id.to_s
    end
    evaluate if do_eval
    Strand.redis.hset TOPICS, @id, @topic.code unless @topic.nil?
    Strand.redis.hset STATUS, @id, @good
  end

  private
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

  def evaluate(reload = true)
    @topic = nil
    @members.each do |member|
      member.association(:link).reload if reload
      @good &&= set_topic member.link&.topic
    end
  end

  def set_topic(topic)
    return true if topic.nil?
    if @topic.nil?
      @topic = topic
    end
    @topic == topic
  end
end