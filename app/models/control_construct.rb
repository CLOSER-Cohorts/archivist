class ControlConstruct < ApplicationRecord
  belongs_to :construct, polymorphic: true
  belongs_to :instrument
  belongs_to :parent, -> { includes :construct }, class_name: 'ControlConstruct'

  has_many :children, -> { includes(:construct).order('position ASC') }, class_name: 'ControlConstruct', foreign_key: 'parent_id', dependent: :destroy

  after_update :clear_cache
  after_destroy :clear_cache

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
