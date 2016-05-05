module ActiveRecordExtension

  extend ActiveSupport::Concern

  included do

    after_create :clear_cached_stats
    after_destroy :clear_cached_stats

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
  end

  # Class methods
  module ClassMethods
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)