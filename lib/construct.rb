module Construct
  extend ActiveSupport::Concern
  included do
    belongs_to :instrument
    has_one :cc, class_name: 'ControlConstruct', as: :construct, dependent: :destroy

    include Realtime

    before_create :create_control_construct

    delegate :label, to: :cc
    delegate :label=, to: :cc
    delegate :position, to: :cc
    delegate :position=, to: :cc

    def parent
      if not self.cc.parent.nil?
        self.cc.parent.construct
      end
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
