class ControlConstruct < ActiveRecord::Base
  belongs_to :construct, polymorphic: true
  belongs_to :parent, -> { includes :construct }, class_name: 'ControlConstruct'
  has_many :children, -> { includes :construct }, class_name: 'ControlConstruct', foreign_key: 'parent_id'
end
