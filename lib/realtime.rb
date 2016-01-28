module Realtime
  extend ActiveSupport::Concern
  included do
    after_commit :rt_update

    private
    def rt_update
      output = self.to_json except: :created_at
      output = JSON.parse output
      output[:type] = self.class.name
      $redis.publish 'rt-update', output.to_json
    end
  end
end