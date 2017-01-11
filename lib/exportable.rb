module Exportable
  extend ActiveSupport::Concern
  class_methods do
    def tag
      [self::NS, self::TYPE].join ':'
    end
  end

  included do
    def urn(urn_prefix = nil, urn_type = nil)
      urn_prefix = ['urn', 'ddi', self.instrument.agency, self.instrument.prefix].join ':' if urn_prefix.nil?
      urn_type = self.class::URN_TYPE if urn_type.nil?
      [urn_prefix, urn_type, '%06d:1.0.0' % self.id].compact.join '-'
    end
  end
end