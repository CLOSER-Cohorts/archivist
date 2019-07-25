# The ControlConstruct model is used to hold the positional information
# for all five of the construct models. Every construct must have one
# ControlConstruct and vice-versa.
#
# This is the abstract class that all five of the control constructs are
# eventually derived from.
#
# === Properties
# * Label
# * Position
# * Parent
# * Branch
class ControlConstruct < ApplicationRecord
  self.abstract_class = true

  # Control constructs are comparable to allow sorting into positional order
  include Comparable

  # This model is an update point for archivist-realtime
  include Realtime::RtUpdate

  # This model is exportable as DDI
  include Exportable

  # Before creating, populate position fields
  before_create :pre_create_position_prep

  # All categories must belong to an {Instrument}
  belongs_to :instrument

  # Each control construct must have one parent, except the top-sequence which has no parent
  belongs_to :parent, polymorphic: true

  # After creating or updating, clear the cache from Redis
  after_save :clear_cache

  # After destroying, clear the cache from Redis
  after_destroy :clear_cache

  # Clears the Redis cache of construct positional information
  def clear_cache
    begin
      unless self.parent_id.nil?
        if self.parent_type == 'CcCondition'
          $redis.ping
          # puts 'Connecting to Redis...'
          # puts "Id: #{self.id}"
          # puts "Parent_id: #{self.parent_id}"
          # puts "Parent_type: #{self.parent_type}"
          $redis.hdel 'construct_children:CcCondition:0', self.parent_id
          $redis.hdel 'construct_children:CcCondition:1', self.parent_id
        else
          $redis.ping
          # puts 'Connecting to Redis...'
          # puts "Id: #{self.id}"
          # puts "Parent_id: #{self.parent_id}"
          # puts "Parent_type: #{self.parent_type}"
          $redis.hdel "construct_children:#{self.parent_type}", self.parent_id
        end
      end
      $redis.hdel 'parents', self.id
      $redis.hdel 'is_top', self.id
   rescue => err
     Rails.logger.warn "Cannot connect to Redis [Control Construct] -> Error: '#{err}'"
   end
  end

  private # Private methods

  def pre_create_position_prep
    self.position = parent&.last_child&.position.to_i + 1 if self.position.nil?
    self.branch = 0 if self.branch.nil?
  end
end
