class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_create :clear_cached_stats
  after_destroy :clear_cached_stats
  after_update :update_last_edit_time

  # Instance methods
  def association_stats
    key = self.class.name + self.id.to_s + 'counts'
    begin
      counts = $redis.get key
    rescue Redis::CannotConnectError
    end
    if counts.nil?
      counts = {}
      self.class.reflections.keys.each do |key|
        if self.class.reflections[key].is_a? ActiveRecord::Reflection::HasManyReflection
          counts[key] = self.send(key).count
        end
      end
      begin
        $redis.set key, counts.to_json
      rescue Redis::CannotConnectError
      end
    else
      counts = JSON.parse counts
    end
    counts
  end

  def clear_cached_stats
    self.class.reflections.keys.each do |key|
      if self.class.reflections[key].is_a? ActiveRecord::Reflection::BelongsToReflection
        unless self.send(key).nil?
          begin
            $redis.del key.classify + self.send(key).id.to_s + 'counts'
          rescue Redis::CannotConnectError
          end
        end
      end
    end
  end

  def update_last_edit_time
    begin
      if self.is_a? Instrument
        $redis.hset 'last_edit:instrument', self.id, self.updated_at
      elsif self.class.method_defined?(:instrument) && self.instrument.is_a?(Instrument)
        $redis.hset 'last_edit:instrument', self.instrument.id, self.updated_at
      end
    rescue
    end
  end
end
