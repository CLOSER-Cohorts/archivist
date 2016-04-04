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
  extend ActiveSupport::Concern
  included do
    after_commit :rt_update

    private
    def rt_update
      output = {}
      #Create JSON string from model
      data = self.to_json except: :created_at
      #Parse it back to a model
      data = JSON.parse data
      #Attach the Class as type
      data[:type] = self.class.name
      #Place the data in the output object
      output[:data] = [data]
      #Publish the output as JSON to the rt-update channel
      $redis.publish 'rt-update', output.to_json
    end
  end
end