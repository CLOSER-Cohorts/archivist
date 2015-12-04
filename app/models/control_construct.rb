class ControlConstruct < ActiveRecord::Base
  belongs_to :construct, polymorphic: true
  belongs_to :parent, class_name: 'ControlConstruct'
end
