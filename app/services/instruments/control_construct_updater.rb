module Instruments
  class ControlConstructUpdater
    include ActiveRecord::Sanitization::ClassMethods

    def initialize(instrument, updates=[])
      @instrument = instrument
      @updates = updates.map{|u| u.to_hash.deep_symbolize_keys! }.select{|u| u[:type].present? && u[:parent][:type].present? }
    end

    def call
      bulk_update
      clear_cache
    end

    private

    def bulk_update
      values = sql_values
      connection.execute(updater_sql(values)) unless values.blank?
    end

    def connection
      ActiveRecord::Base.connection
    end

    def sql_values
      @updates.map do | u |
        next unless u.keys.sort == [:branch, :id, :parent, :position, :type]
        sanitize_sql([
            "(:construct_id, :construct_type, :position, :branch, :parent_id, :parent_type)",
            {
              construct_id: u[:id],
              construct_type: db_type(u[:type]),
              position: u[:position],
              branch: u[:branch],
              parent_id: u[:parent][:id],
              parent_type: db_type(u[:parent][:type])
            }
          ])
      end.join(',')
    end

    def db_type(type)
      case type.downcase
        when 'condition' then
          'CcCondition'
        when 'loop' then
          'CcLoop'
        when 'question' then
          'CcQuestion'
        when 'sequence' then
          'CcSequence'
        when 'statement' then
          'CcStatement'
      end
    end

    def updater_sql(values)
      %|
        UPDATE control_constructs
        SET
          position = myvalues.position,
          branch = myvalues.branch,
          parent_id = (SELECT id FROM control_constructs WHERE construct_type = myvalues.parent_type AND construct_id = myvalues.parent_id),
          updated_at = NOW()
        FROM (
          VALUES
            #{values}
        ) AS myvalues (construct_id, construct_type, position, branch, parent_id, parent_type)
        WHERE control_constructs.construct_id = myvalues.construct_id
        AND control_constructs.construct_type = myvalues.construct_type;
      |
    end

    # Clears the Redis cache of construct positional information
    def clear_cache
      @updates.each do | u |
        id = u[:id]
        parent_id = u[:parent][:id]
        parent_type = db_type(u[:parent][:type])
        begin
          unless parent_id.nil?
            if parent_type == 'CcCondition'
              $redis.ping
              $redis.hdel 'construct_children:CcCondition:0', parent_id
              $redis.hdel 'construct_children:CcCondition:1', parent_id
            else
              $redis.ping
              $redis.hdel "construct_children:#{parent_type}", parent_id
            end
          end
          $redis.hdel 'parents', id
          $redis.hdel 'is_top', id
       rescue => err
         Rails.logger.warn "Cannot connect to Redis [Control Construct] -> Error: '#{err}'"
       end
      end
    end
  end
end
