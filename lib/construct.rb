module Construct
  extend ActiveSupport::Concern
  included do
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
      reflect_on_association(:cc).klass.send :has_many, :children, class_name: 'ControlConstruct', foreign_key: 'parent_id'
      include Construct::LocalInstanceMethods
    end
  end
  
  module LocalInstanceMethods    
    def children
      @children
    end
  end
end