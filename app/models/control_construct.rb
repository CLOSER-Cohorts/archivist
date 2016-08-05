class ControlConstruct < ActiveRecord::Base
  belongs_to :construct, polymorphic: true
  belongs_to :parent, -> { includes :construct }, class_name: 'ControlConstruct'
  has_many :children, -> { includes(:construct).order('position ASC') }, class_name: 'ControlConstruct', foreign_key: 'parent_id', dependent: :destroy
  belongs_to :instrument
end
