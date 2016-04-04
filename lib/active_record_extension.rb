module ActiveRecordExtension

  extend ActiveSupport::Concern

  included do

    after_create :clear_cached_stats
    after_destroy :clear_cached_stats

    # Instance methods
    def association_stats
      key = self.class.name + self.id.to_s + 'counts'
      counts = $redis.get key
      if counts.nil?
        counts = {}
        self.class.reflections.keys.each do |key|
          if self.class.reflections[key].is_a? ActiveRecord::Reflection::HasManyReflection
            counts[key] = self.send(key).count
          end
        end
        $redis.set key, counts.to_json
      else
        counts = JSON.parse counts
      end
      counts
    end

    def clear_cached_stats
      self.class.reflections.keys.each do |key|
        if self.class.reflections[key].is_a? ActiveRecord::Reflection::BelongsToReflection
          unless self.send(key).nil?
            $redis.del key.classify + self.send(key).id.to_s + 'counts'
          end
        end
      end
    end
  end

  # Class methods
  module ClassMethods
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)