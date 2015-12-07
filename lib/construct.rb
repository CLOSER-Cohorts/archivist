module Construct
  extend ActiveSupport::Concern
  included do
    belongs_to :instrument
    has_one :cc, class_name: 'ControlConstruct', as: :construct
    before_create :create_control_construct
    
    def parent
      self.cc.parent.construct
    end
    
    def parent=(new_parent)
      self.cc.parent = new_parent.cc
    end
    
    def create_control_construct
      self.cc = ControlConstruct.new
      true
    end
  end
  
  module ClassMethods
    def is_a_parent(options = {})
      include Linkable
      include Construct::LocalInstanceMethods
      delegate :children, to: :cc
    end
  end
  
  module LocalInstanceMethods    
  end
end
