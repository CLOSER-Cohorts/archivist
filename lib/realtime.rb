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