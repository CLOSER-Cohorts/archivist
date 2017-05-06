module Construct
end

module Construct::Model
  extend ActiveSupport::Concern
  included do
    belongs_to :instrument
    has_one :cc, class_name: 'ControlConstruct', as: :construct, dependent: :destroy

    include Comparable
    include Realtime::RtUpdate
    include Exportable
    # This model can be tracked using an Identifier
    include Identifiable

    before_create :create_control_construct
    delegate :label=, to: :cc
    delegate :position, to: :cc
    delegate :position=, to: :cc
    delegate :branch, to: :cc
    delegate :branch=, to: :cc

    def self.attribute_names
      super + ['label']
    end

    def parent
      unless self.cc.parent.nil?
        begin
          $redis.hset 'parents:' + self.class.to_s, self.id, self.cc.parent.construct.id
          $redis.hset 'is_top:' + self.class.to_s, self.id, self.cc.parent.nil?
        rescue
          Rails.logger.warn 'Could not update parents and is_top to Redis cache.'
        end
        self.cc.parent.construct
      end
    end

    def parent=(new_parent)
      self.cc.parent = new_parent.cc
    end

    def parent_id
      begin
        pid = $redis.hget 'parents:' + self.class.to_s, self.id
      rescue
        Rails.logger.warn 'Could not retrieve parents from Redis cache.'
      end
      if pid.nil?
        pid = self.parent.nil? ? nil : self.parent.id
      end
      pid.to_i
    end

    def first_parent_of(klass)
      p = self.parent
      p = p.parent until p.is_a?(klass) || p.nil?
      p
    end

    def label
      self.cc.label.nil? ? '' : self.cc.label
    end

    def is_top?
      begin
        top = $redis.hget 'is_top', self.id
      rescue
        Rails.logger.warn 'Could not retrieve is_top from Redis cache.'
      end
      top.nil? ? self.parent.nil? : top
    end

    def create_control_construct
      if self.cc.nil?
        self.cc = ControlConstruct.new instrument_id: Prefix[instrument_id]
      end
      true
    end

    def <=> other
      return unless other.is_a? self.class
      if (self.cc.parent_id == other.cc.parent_id)
        return self.cc.position <=> other.cc.position
      else
        return 1 if self.parent&.position.nil?
        return -1 if other.parent&.position.nil?
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
    def is_a_parent
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

    def create_with_position(params, defer = false)
      obj = new()
      i = Instrument.find(Prefix[params[:instrument_id]])
      obj.instrument = i unless defer
      obj.cc = i.control_constructs.new

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

      i.send('cc_' + params[:type].pluralize) << obj if defer

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
      query_children = lambda do |query_branch, cc|
        if query_branch.nil?
          return cc.children.map { |c| {id: c.construct.id, type: c.construct.class.name } }
        else
          return cc.children.where(branch: query_branch).map { |c| {id: c.construct.id, type: c.construct.class.name } }
        end
      end

      begin
        cs = $redis.hget 'construct_children:' +
                             self.class.to_s +
                             (branch.nil? ? '' : (':' + branch.to_s)), self.id

        if cs.nil?
          cs = query_children.call branch, self.cc
          $redis.hset 'construct_children:' +
                          self.class.to_s +
                          (branch.nil? ? '' : (':' + branch.to_s)), self.id,  cs.to_json
        else
          cs = JSON.parse cs
        end
      rescue
        cs = query_children.call branch, self.cc
      end
      cs
    end
  end
end
