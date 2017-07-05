module Construct
end

module Construct::Model
  extend ActiveSupport::Concern
  included do
    belongs_to :instrument

    include Comparable
    include Realtime::RtUpdate
    include Exportable

    before_create :create_control_construct

    def parent
      unless self.parent.nil?
        begin
          $redis.hset 'parents:' + self.class.to_s, self.id, self.parent.construct.id
          $redis.hset 'is_top:' + self.class.to_s, self.id, self.parent.nil?
        rescue
          Rails.logger.warn 'Could not update parents and is_top to Redis cache.'
        end
        self.parent
      end
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

    def is_top?
      begin
        top = $redis.hget 'is_top', self.id
      rescue
        Rails.logger.warn 'Could not retrieve is_top from Redis cache.'
      end
      top.nil? ? self.parent.nil? : top
    end

    def <=> other
      return unless other.is_a? self.class
      if (self.parent_id == other.parent_id)
        return self.position <=> other.position
      else
        return 1 if self.parent&.position.nil?
        return -1 if other.parent&.position.nil?
        return self.parent.position <=> other.parent.position
      end
    end
  end

  module ClassMethods
    def is_a_parent
      include LinkableParent
      include Construct::Model::LocalInstanceMethods
    end

=begin
    def create_with_position(params, defer = false)
      obj = new()
      i = Instrument.find(Prefix[params[:instrument_id]])
      obj.instrument = i unless defer
      obj.cc = i.control_constructs.new

      parent = i.send('cc_' + params[:parent][:type].tableize).find(params[:parent][:id])
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
=end
  end

  module LocalInstanceMethods
    def all_children_ccs
      sql = <<~SQL
        WITH RECURSIVE cc_tree AS 
        (
           SELECT
              ccl.*,
              1 AS level 
           FROM
              cc_links AS ccl 
           WHERE
              construct_id = ? 
              AND construct_type = ? 
           UNION ALL
           SELECT
              ccl.*,
              tree.level + 1 
           FROM
              cc_links AS ccl 
              JOIN
                 cc_tree AS tree 
                 ON tree.id = ccl.parent_id
        )
        SELECT
           tree.* 
        FROM
           cc_tree AS tree
        WHERE
           NOT (
              tree.construct_id = ? 
              AND tree.construct_type = ? 
           )
      SQL

      #TODO: This needs updating
      ::ControlConstruct.find_by_sql([
                            sql,
                            self.id,
                            self.class.name,
                            self.id,
                            self.class.name
                        ])
    end

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

module Construct::Controller
  extend ActiveSupport::Concern
  included do
    def set_topic
      super do
        Realtime::Publisher.instance.batch_update @object.all_children_ccs.map { |cc| cc.construct }
      end
    end
  end
end