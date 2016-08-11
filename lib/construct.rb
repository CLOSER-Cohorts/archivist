module Construct
end

module Construct::Model
  extend ActiveSupport::Concern
  included do
    belongs_to :instrument
    has_one :cc, class_name: 'ControlConstruct', as: :construct, dependent: :destroy

    include Comparable
    include Realtime::RtUpdate

    before_create :create_control_construct
    delegate :label, to: :cc
    delegate :label=, to: :cc
    delegate :position, to: :cc
    delegate :position=, to: :cc
    delegate :branch, to: :cc
    delegate :branch=, to: :cc

    def self.attribute_names
      super + ["label"]
    end

    def parent
      unless self.cc.parent.nil?
        begin
          $redis.hset 'parents', self.id, self.cc.parent.id
          $redis.hset 'is_top', self.id, self.cc.parent.nil?
        rescue
        end
        self.cc.parent.construct
      end
    end

    def parent=(new_parent)
      self.cc.parent = new_parent.cc
    end

    def parent_id
      begin
        pid = $redis.hget 'parents', self.id
      rescue
      end
      if pid.nil?
        pid = self.parent.nil? ? nil : self.parent.id
      end
      pid.to_i
    end

    def is_top?
      begin
        top = $redis.hget 'is_top', self.id
      rescue
      end
      top.nil? ? self.parent.nil? : top
    end

    def create_control_construct
      if self.cc.nil?
        self.cc = ControlConstruct.new instrument_id: instrument_id
      end
      true
    end

    def <=> other
      return unless other.is_a? self.class
      if (self.cc.parent_id == other.cc.parent_id)
        return self.cc.position <=> other.cc.position
      else
        return 1 if self.cc.parent_id.nil? || self.parent.position.nil?
        return -1 if other.cc.parent_id.nil? || other.parent.position.nil?
        return self.parent.position <=> other.parent.position
      end
    end

    def update(params)
      super params
      logger.debug params
      self.cc.update label: params[:label]
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
          .joins('INNER JOIN control_constructs ON cc_questions.id = construct_id AND control_constructs.construct_type = \'CcQuestion\'')
          .where('label = ?', label)
          .first
    end

    def create_with_position(params)
      obj = new()
      i = Instrument.find(params[:instrument_id])
      #i.send('cc_' + params[:type].pluralize) << obj
      obj.instrument = i
      obj.cc = ControlConstruct.new instrument_id: i.id

      parent = i.send('cc_' + params[:parent][:type].pluralize).find(params[:parent][:id])
      unless parent.nil?
        if parent.has_children?
          obj.position = parent.last_child.position + 1
        else
          obj.position = 1
        end

        unless params[:branch].nil?
          obj.branch = params[:branch]
        end
      end
      obj.label = params[:label]

      yield obj

      obj.transaction do
        obj.save!
        parent.children << obj.cc
      end
      obj.cc.clear_cache
      obj
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

    def construct_children(branch = nil)
      begin
        cs = $redis.hget 'construct_children:' +
                             self.class.to_s +
                             (branch.nil? ? '' : (':' + branch.to_s)), self.id

        if cs.nil?
          if branch.nil?
            cs = self.cc.children.map { |c| {id: c.construct.id, type: c.construct.class.name } }
          else
            cs = self.cc.children.where(branch: branch).map { |c| {id: c.construct.id, type: c.construct.class.name } }
          end
          $redis.hset 'construct_children:' +
                          self.class.to_s +
                          (branch.nil? ? '' : (':' + branch.to_s)), self.id,  cs.to_json
        else
          cs = JSON.parse cs
        end
      rescue
        if branch.nil?
          cs = self.cc.children.map { |c| {id: c.construct.id, type: c.construct.class.name } }
        else
          cs = self.cc.children.where(branch: branch).map { |c| {id: c.construct.id, type: c.construct.class.name } }
        end
      end
      cs
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
