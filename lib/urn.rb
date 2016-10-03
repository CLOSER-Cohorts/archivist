module URN
  extend ActiveSupport::Concern

  included do
    def URN
      self.instrument.prefix + '-' + self.class::URN_TYPE + "-%06d:1.0.0" % self.id
    end
  end

  class_methods do

  end
end