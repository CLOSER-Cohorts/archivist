module Mappable
  extend ActiveSupport::Concern
  included do
    def typed_id
      self.class.name + ':' + self.id.to_s
    end
  end
end