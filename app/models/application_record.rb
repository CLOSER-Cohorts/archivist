# ApplicationRecord should not be used direct, but rather serves as the base model for
# all other Archivist models.
#
# This model contains all the functionality that should apply to models that use a SQL
# database table to store data.
#
# This is an abstract class.
class ApplicationRecord < ActiveRecord::Base
  # Declare as an abstract class
  self.abstract_class = true

  # Call clear_cached_stats whenever a model is created
  after_create :clear_cached_stats

  # Call clear_cached_stats whenever a model is destroyed
  after_destroy :clear_cached_stats

  # Call update_last_edit_item after the model has been updated
  after_update :update_last_edit_time


  ## Instance methods ##

  # Returns a hash of counts of each associated model
  #
  # This method uses associations reflections to iterate over all relationships and perform counts.
  # If the counts have been generated before, they will be retrieved from Redis instead of
  # re-performing counts using SQL.
  #
  # ==== Returns
  # Hash { Symbol(Association) : Integer(Count) , ... }
  #
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

  # Deletes all cached counts from Redis
  #
  # Clears any counts cached by `association_stats` from Redis.
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

  # Updates the last edit time of the parent instrument in Redis
  #
  # If the model is either an instrument or a child model of an instrument (belongs_to instrument)
  # then the last edited time (updated_at) of the instrument is updated in Redis.
  #
  # === ToDo
  # * Move this method (and corresponding action) to a base model of just instrument models
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
