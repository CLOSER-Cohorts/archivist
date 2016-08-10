# The Realtime module connects a model to Redis via the RT Update channel
#
# By including the Realtime module in model all commits to the database made
# by this model will publish an update to Redis on the RT Update channel. The
# practical upshot of this is that realtime updates can be publish to all
# current Archivist users so there is no need to manually refresh their browers.
#
# ==== Use by
#
#   include Realtime
#
# === Todo
#
# * Allow for options to exclude certain database actions
# * Allow for options to alter the output packet before publishing
# * Potentially provide option for pre/post publish filter with stopping option
#
module Realtime
  module RtUpdate
    extend ActiveSupport::Concern
    included do
      after_commit :rt_create, on: :create
      after_commit :rt_update, on: :update
      after_commit :rt_destroy, on: :destroy

      private
      def rt_create
        Realtime::Publisher.instance.update self, 'ADD'
        if self.is_a?(Construct::Model) && !self.parent.nil?
          Realtime::Publisher.instance.update self.parent
        end
      end
      def rt_update
        Realtime::Publisher.instance.update self
      end
      def rt_destroy
        Realtime::Publisher.instance.update self, 'DEL'
        if self.is_a?(Construct::Model) && !self.parent.nil?
          Realtime::Publisher.instance.update self.parent
        end
      end
    end
  end
  class Publisher
    include Singleton
    def initialize
      @quiet = false
    end

    def go_quiet
      @quiet = true
    end

    def go_loud
      @quiet = false
    end

    def update(obj, action = '')
      unless @quiet
        output = {}
        #Create JSON from model
        if obj.class.method_defined? :rt_attributes
          data = obj.rt_attributes
        else
          data = obj.as_json except: [:created_at, :updated_at]
        end
        #Attach the Class as type
        data[:type] = obj.class.name
        #Place the data in the output object
        output[:data] = [data]
        output[:data][0][:action] = action
        #Publish the output as JSON to the rt-update channel
        begin
          $redis.publish 'rt-update', output.to_json
        rescue
        end
      end
    end
  end

  def self.go_quiet
    Realtime::Publisher.instance.go_quiet
  end

  def self.go_loud
    Realtime::Publisher.instance.go_loud
  end

  def self.do_silently
    go_quiet
    yield
    go_loud
  end
end