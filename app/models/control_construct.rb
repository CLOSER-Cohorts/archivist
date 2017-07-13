# The ControlConstruct model is used to hold the positional information
# for all five of the construct models. Every construct must have one
# ControlConstruct and vice-versa.
#
# === Properties
# * Label
# * Position
# * Parent
# * Branch
class ControlConstruct < ApplicationRecord
  # Every ControlConstruct _must_ have one construct
  belongs_to :construct, polymorphic: true

  # All categories must belong to an {Instrument}
  belongs_to :instrument

  # Every ControlConstruct must have a parent, with the exception of the top sequence
  belongs_to :parent, -> { includes :construct }, class_name: 'ControlConstruct'

  # Get a collection of constructs that have this model as a parent
  has_many :children, -> { includes(:construct).order('position ASC') }, class_name: 'ControlConstruct', foreign_key: 'parent_id', dependent: :destroy

  # After updating, clear the cache from Redis
  after_update :clear_cache

  # After destroying, clear the cache from Redis
  after_destroy :clear_cache

  # All ControlConstructs require position and a construct
  validates :construct, :position, presence: true

  # Clears the Redis cache of construct positional information
  def clear_cache
    begin
      unless self.parent.nil?
        if self.parent.construct_type == 'CcCondition'
          $redis.hdel 'construct_children:CcCondition:0', self.parent.construct_id
          $redis.hdel 'construct_children:CcCondition:1', self.parent.construct_id
        else
          $redis.hdel 'construct_children:' + self.parent.construct_type, self.parent.construct_id
        end
      end
      $redis.hdel 'parents', self.construct_id
      $redis.hdel 'is_top', self.construct_id
    rescue
      Rails.logger.warn 'Cannot connect to Redis'
    end
  end
end
