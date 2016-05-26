module Construct
end

module Construct::Model
  extend ActiveSupport::Concern
  included do
    belongs_to :instrument
    has_one :cc, class_name: 'ControlConstruct', as: :construct, dependent: :destroy

    include Comparable
    include Realtime

    before_create :create_control_construct

    delegate :label, to: :cc
    delegate :label=, to: :cc
    delegate :position, to: :cc
    delegate :position=, to: :cc
    delegate :branch, to: :cc
    delegate :branch=, to: :cc

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

    def <=> other
      if (self.cc.parent_id == other.cc.parent_id)
        return self.cc.position <=> other.cc.position
      else
        return 1 if self.cc.parent_id.nil? || self.parent.position.nil?
        return -1 if other.cc.parent_id.nil? || other.parent.position.nil?
        return self.parent.position <=> other.parent.position
      end
    end
  end

  module ClassMethods
    def is_a_parent(options = {})
      include Linkable
      include Construct::Model::LocalInstanceMethods
      delegate :children, to: :cc
    end

    def find_by_label(label)
        self
          .where(nil)
          .joins('INNER JOIN control_constructs ON cc_questions.id = construct_id AND construct_type = \'CcQuestion\'')
          .where('label = ?', label)
          .first
    end
  end

  module LocalInstanceMethods
    def first_child
      children.min_by { |x| x.position}
    end

    def last_child
      children.max_by { |x| x.position}
    end

    def has_children?
      children.count > 0
    end
  end
end

module Construct::Controller
  extend ActiveSupport::Concern
  include BaseInstrumentController
  included do
  end

  module ClassMethods
    def add_basic_actions(options = {})
      super options
      include Construct::Controller::Actions
    end
  end

  module Actions
    def create
      #TODO: Security issue
      @object = collection.create_with_position(params)
      if @object
        render :show, status: :created
      else
        render json: @object.errors, status: :unprocessable_entity
      end
    end
  end
end
