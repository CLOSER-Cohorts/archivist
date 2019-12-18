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

    def exploded_urn
      @exploded_urn ||= OpenStruct.new(
        agency: self.instrument.agency,
        version: '1.0.0',
        id: [self.instrument.prefix, self.class::URN_TYPE, '%06d' % self.id].compact.join('-'),
        type_of_object: self.class.name
      )
    end
  end
end
