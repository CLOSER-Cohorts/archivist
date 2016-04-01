module ActiveRecordExtension

  extend ActiveSupport::Concern

  # Instance methods
  def association_stats
    key = self.class.name + self.id.to_s + 'counts'
    counts = $redis.get key
    if counts.nil?
      counts = {}
      self.class.reflections.keys.each do |key|
        counts[key] = self.send(key).count
      end
      $redis.set key, counts.to_json
    end
    counts
  end

  # Class methods
  module ClassMethods
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)