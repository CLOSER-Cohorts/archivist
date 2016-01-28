module Realtime
  extend ActiveSupport::Concern
  included do
    after_commit :rt_update

    private
    def rt_update
      output = {}
      data = self.to_json except: :created_at
      output[:data] = self.to_json except: :created_at
      data = JSON.parse data
      data.type = self.class.name
      output[:data] = [data]
      $redis.publish 'rt-update', output.to_json
    end
  end
end