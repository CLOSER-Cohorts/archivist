class Strand
  SCOPE = 'mapper:strands'
  LOOKUP = SCOPE + ':lookup'
  TOPICS = SCOPE + ':topics'

  include ActiveModel::Model

  attr_accessor :id, :topic
  attr_reader :members, :good

  def initialize(members = [])
    @members = members
    @good = true
    @members.each do |member|
      @good &&= set_topic member.topic
    end
  end

  def load
    unless @id.nil?
      Strand.redis.smembers(SCOPE + ':' + @id.to_s).each do |member|
        class_name, id = member.split ':'
        @members.push class_name.constantize.find id
      end
      topic_code = Strand.redis.hget TOPICS, @id
      unless topic_code.nil?
        @topic = Topic.find_by_code topic_code
      end
    end
    self
  end

  def save
    if @id.nil?
      @id = Strand.redis.incr SCOPE + ':count'
    end
    Strand.redis.sadd SCOPE + ':' + @id.to_s, @members.map(&:typed_id)
    @members.each do |member|
      Strand.redis.hset LOOKUP, member.id, @id.to_s
    end
    Strand.redis.hset TOPICS, @id, @topic.code unless @topic.nil?
  end

  def delete
    unless @id.nil?
      Strand.redis.del SCOPE + ':' + @id.to_s
      @members.each do |member|
        Strand.redis.hdel LOOKUP, member.id
      end
      Strand.redis.hdel TOPICS, @id
    end
    @members = []
    @id = nil
    @topic = nil
  end

  def +(other)
    new_members = []
    new_members += @members
    new_members += other.members
    delete
    other.delete
    Strand.new new_members
  end

  def self.find_by_member(member)
    id = redis.hget LOOKUP, member.id
    return nil if id.nil?
    new_strand = Strand.new
    new_strand.id = id.to_i
    new_strand.load
    return new_strand
  end

  private
  def set_topic(topic)
    return true if topic.nil?
    if @topic.nil?
      @topic = topic
    end
    return @topic == topic
  end


  def self.redis
    $redis
  end
end