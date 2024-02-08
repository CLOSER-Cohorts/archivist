module Exportable
  extend ActiveSupport::Concern

  class_methods do
    def tag
      [self::NS, self::TYPE].join ':'
    end
  end

  included do
    def ddi_slug
      super || self.id.to_s
    end

    def urn=(value)
      value.match(/urn:ddi:(?<instrument_agency>.*):(?<instrument_prefix>.*)-(?<type>.*)-(?<id>.*):(.*)/)
      self.ddi_slug = $~[:id]
    end

    def urn(urn_prefix = nil, urn_type = nil)
      urn_prefix = ['urn', 'ddi', self.instrument.agency, self.instrument.prefix].join ':' if urn_prefix.nil?
      urn_type = self.class::URN_TYPE if urn_type.nil?
      # Use ddi_slug instead of id
      [urn_prefix, urn_type, "#{self.ddi_slug}:1.0.0"].compact.join '-'
    end

    def exploded_urn
      @exploded_urn ||= OpenStruct.new(
        agency: self.instrument.agency,
        version: '1.0.0',
        # Use ddi_slug instead of id
        id: [self.instrument.prefix, self.class::URN_TYPE, self.ddi_slug].compact.join('-'),
        type_of_object: self.class.name
      )
    end
  end
end
